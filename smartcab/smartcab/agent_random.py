import random
from collections import OrderedDict

import numpy as np
import pandas as pd
import multiprocessing

from environment import Agent, Environment
from planner import RoutePlanner
from simulator import Simulator

class LearningAgent(Agent):
    """An agent that learns to drive in the smartcab world."""

    def __init__(self, env):
        super(LearningAgent, self).__init__(env)  # sets self.env = env, state = None, next_waypoint = None, and a default color
        self.color = 'red'  # override color
        self.planner = RoutePlanner(self.env, self)  # simple route planner to get next_waypoint
        # TODO: Initialize any additional variables here
        self.results = OrderedDict()
        self.result_trial_index = 0
        self.step_index = 1


    def reset(self, destination=None):
        self.planner.route_to(destination)
        # TODO: Prepare for a new trip; reset any variables here, if required
        self.result_trial_index += 1
        self.step_index = 1


    def update(self, t):
        # Gather inputs
        self.next_waypoint = self.planner.next_waypoint()  # from route planner, also displayed by simulator
        inputs = self.env.sense(self)
        deadline = self.env.get_deadline(self)

        # TODO: Update state

        # TODO: Select action according to your policy
        action = random.choice([None, 'forward', 'left', 'right'])

        # Execute action and get reward
        reward = self.env.act(self, action)

        # TODO: Learn policy based on state, action, reward
        if self.result_trial_index not in self.results.keys():
            self.results[self.result_trial_index] = OrderedDict()
        self.results[self.result_trial_index][self.step_index] = {'deadline': deadline, 'reward': reward}
        self.step_index += 1

        print "LearningAgent.update(): deadline = {}, inputs = {}, action = {}, reward = {}".format(deadline, inputs, action, reward)  # [debug]





def run():
    """Run the agent for a finite number of trials."""

    # Set up environment and agent
    e = Environment()  # create environment (also adds some dummy traffic)
    a = e.create_agent(LearningAgent)  # create agent
    e.set_primary_agent(a, enforce_deadline=True)  # specify agent to track
    # NOTE: You can set enforce_deadline=False while debugging to allow longer trials

    # Now simulate it
    sim = Simulator(e, update_delay=0.5, display=True)  # create simulator (uses pygame when display=True, if available)
    # NOTE: To speed up simulation, reduce update_delay and/or set display=False

    sim.run(n_trials=100)  # run for a specified number of trials
    # NOTE: To quit midway, press Esc or close pygame window, or hit Ctrl+C on the command-line
    return a.results


def run_evaluation(index):
    result = run()
    last_20_trips = {k:v for k, v in result.iteritems() if k >= 80}
    last_step_results_20trips = OrderedDict()
    for trip_index, trip_result in last_20_trips.iteritems():
        first_step_index = min(trip_result.keys())
        distance = (trip_result[first_step_index]['deadline'] / 5.0)
        last_step_index = max(trip_result.keys())
        last_step_results_20trips[trip_index] = trip_result[last_step_index]
        trial_time_used_normalized = (trip_result[first_step_index]['deadline'] - trip_result[last_step_index]['deadline']) / distance
        last_step_results_20trips[trip_index]['time_used_normalized'] = trial_time_used_normalized

    last_step_results_20trips_df = pd.DataFrame(last_step_results_20trips).transpose()
    last_step_results_20trips_df.loc[:, 'success'] = 0
    last_step_results_20trips_df.loc[(last_step_results_20trips_df.deadline >= 0) & (last_step_results_20trips_df.reward >= 10), 'success'] = 1
    evaluation = last_step_results_20trips_df[['success', 'time_used_normalized']].mean()

    last_step_results_20trips_df.to_csv('output/random/last_step_results_20trips_df_%s.csv' % index, index=False)
    return evaluation.to_frame().transpose()


def main():
    num_threads = 8
    pool = multiprocessing.Pool(processes=num_threads)
    evaluation_list = pool.map(run_evaluation, (index for index in xrange(10)))
    all20trips_eval = pd.concat(evaluation_list, ignore_index=True)
    pool.close()

    all20trips_eval.to_csv('output/random/final_performance_across_test_simulation_last20trips.csv')


if __name__ == '__main__':
    main()
