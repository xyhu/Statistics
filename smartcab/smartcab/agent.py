import os
import random
from collections import OrderedDict

import numpy as np
import pandas as pd
import multiprocessing

from environment import Agent, Environment
from planner import RoutePlanner
from simulator import Simulator

SAVE_PATH = '/Users/huxiangyu/Dropbox/study/udacity/MLND/projects/smartcab/output/initial10/'

class LearningAgent(Agent):
    """An agent that learns to drive in the smartcab world."""

    def __init__(self, env, alpha=0.1, gamma=0.1):
        super(LearningAgent, self).__init__(env)  # sets self.env = env, state = None, next_waypoint = None, and a default color
        self.color = 'red'  # override color
        self.planner = RoutePlanner(self.env, self)  # simple route planner to get next_waypoint
        # TODO: Initialize any additional variables here
        self.q_table = {}
        self.previous_state_action = None
        self.alpha = alpha
        self.gamma = gamma
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
        inputs = self.env.sense(self) # returns {'light': light, 'oncoming': oncoming, 'left': left, 'right': right}
        deadline = self.env.get_deadline(self)

        # TODO: Update state
        self.state = (inputs['light'], inputs['oncoming'], inputs['left'], inputs['right'], self.next_waypoint)

        # TODO: Select action according to your policy
        # FIRST, it chooses an action randomly
        action = random.choice([None, 'forward', 'left', 'right'])

        # SECOND, IF the q-table has q-values for the state and all 4 actions
        # then choose the action that return highest q-value
        if self.q_table:
            # obtain state_action_key for the current state currently stored in q tables
            candidate_keys = [key for key in self.q_table.keys() if self.state in key]
            # for one state, there could be 4 actions associated, need to make sure all 4 actions are recorded in the q table before using it
            if len(candidate_keys) == 4:
                candidate_dict = {k:v for k,v in self.q_table.items() if k in candidate_keys}
                # choose the action that has highest q value for the state
                selected_key = max(candidate_keys, key=lambda key: self.q_table[key])
                action = selected_key[1]
                # print "candidate_keys = {}, candidate_dict = {}".format(candidate_keys, candidate_dict)

        # Execute action and get reward
        reward = self.env.act(self, action)

        # TODO: Learn policy based on state, action, reward
        state_action_key = (self.state, action)
        # for initial
        if state_action_key not in self.q_table.keys():
            self.q_table[state_action_key] = reward

        # update
        if self.previous_state_action:
            self.q_table[self.previous_state_action] = (1 - self.alpha) * \
                self.q_table[self.previous_state_action] + \
                self.alpha * (reward + self.gamma * self.q_table[state_action_key])
        # store current to use as previous for the next round
        self.previous_state_action = state_action_key

        # print "LearningAgent.update(): deadline = {}, inputs = {}, action = {},reward = {}".format(deadline, inputs, action, reward)  # [debug]

        if self.result_trial_index not in self.results.keys():
            self.results[self.result_trial_index] = OrderedDict()
        self.results[self.result_trial_index][self.step_index] = {'deadline': deadline, 'reward': reward}
        self.step_index += 1


def sub_run(params):
    alpha = params[0]
    gamma = params[1]
    e = Environment()  # create environment (also adds some dummy traffic)
    a = e.create_agent(LearningAgent, alpha=alpha, gamma=gamma)  # create agent
    e.set_primary_agent(a, enforce_deadline=True)  # specify agent to track
    # NOTE: You can set enforce_deadline=False while debugging to allow longer trials

    # Now simulate it
    sim = Simulator(e, update_delay=0.0001, display=False)  # create simulator (uses pygame when display=True, if available)
    # NOTE: To speed up simulation, reduce update_delay and/or set display=False

    # sim.run(n_trials=2)  # NEED TO CHANGE FOR FINAL SUBMISSION: run for a specified number of trials
    sim.run(n_trials=1000)
    return {params: a.results}

def run():
    # create the process pool
    num_threads = 8
    pool = multiprocessing.Pool(processes=num_threads)
    """Run the agent for a finite number of trials."""
    # eval_results = {} # key = (alpha, gamma)
    # Set up environment and agent
    seq_0_1 = np.linspace(0.1, 0.5, 5)
    seq_0_2 = np.linspace(0.1, 0.9, 9)
    # seq_0_1 = [0.5] # NEED TO CHANGE FOR FINAL SUBMISSION: run for a specified number of trials
    result_list = pool.map(sub_run, ((alpha, gamma) for alpha in seq_0_1 for gamma in seq_0_2))
    pool.close()

    return result_list

def evaluation(eval_results, index):
    success_count = OrderedDict()
    total_eval_trips = OrderedDict()
    time_used_normalized = OrderedDict()
    pos_reward = OrderedDict()
    neg_reward = OrderedDict()
    total_reward_normalized = OrderedDict()

    # for params, params_result in eval_results.iteritems():
    for result in eval_results:
        for params, params_result in result.iteritems():
            time_used_normalized_list = []
            pos_reward_list = []
            neg_reward_list = []
            total_reward_normalized_list = []
            for trial, trial_result in params_result.iteritems():
                # evaluate on only the later 100 trips because the first 900 agent is learning
                if trial >= 900:
                    trial_result_df = pd.DataFrame(trial_result).transpose()
                    total_eval_trips[params] = 1 if params not in total_eval_trips.keys() else total_eval_trips[params] + 1
                    # print trial_result_df
                    if trial_result_df.iloc[-1]['deadline'] >= 0 and trial_result_df.iloc[-1]['reward'] >= 10:
                        # distance * 5 = deadline (environment.py line 97)
                        distance = (trial_result_df.iloc[1]['deadline'] / 5.0)
                        success_count[params] = 1 if params not in success_count.keys() else success_count[params] + 1
                        trial_time_used_normalized = (trial_result_df.iloc[1]['deadline'] - trial_result_df.iloc[-1]['deadline']) / distance
                        time_used_normalized_list.append(trial_time_used_normalized)
                        trial_pos_reward = trial_result_df.loc[trial_result_df.reward >= 0, 'reward'].sum()
                        trial_neg_reward = trial_result_df.loc[trial_result_df.reward < 0, 'reward'].sum()
                        trial_total_reward_normalized = (trial_pos_reward + trial_neg_reward) / distance
                        pos_reward_list.append(trial_pos_reward)
                        neg_reward_list.append(trial_neg_reward)
                        total_reward_normalized_list.append(trial_total_reward_normalized)

            if time_used_normalized_list:
                time_used_normalized[params] = np.mean(time_used_normalized_list)
            if pos_reward_list:
                pos_reward[params] = np.mean(pos_reward_list)
            if neg_reward_list:
                neg_reward[params] = np.mean(neg_reward_list)
            if total_reward_normalized_list:
                total_reward_normalized[params] = np.mean(total_reward_normalized_list)

    success_count_df = pd.DataFrame({'params': success_count.keys(), 'num_successes': success_count.values()})
    total_eval_trips_df = pd.DataFrame({'params': total_eval_trips.keys(), 'num_eval_trips': total_eval_trips.values()})
    time_used_normalized_df = pd.DataFrame({'params': time_used_normalized.keys(), 'average_time_used_normalized': time_used_normalized.values()}) # for success trials
    pos_reward_df = pd.DataFrame({'params': pos_reward.keys(), 'average_pos_reward': pos_reward.values()}) # for success trials
    neg_reward_df = pd.DataFrame({'params': neg_reward.keys(), 'average_neg_reward': neg_reward.values()}) # for success trials
    total_reward_normalized_df = pd.DataFrame({'params': total_reward_normalized.keys(), 'average_total_reward_normalized': total_reward_normalized.values()}) # for success trials
    merge_list = [success_count_df, total_eval_trips_df, time_used_normalized_df, pos_reward_df, neg_reward_df, total_reward_normalized_df]
    merged_result = reduce(lambda left, right: left.merge(right, on='params'), merge_list)
    merged_result.loc[:, 'success_rate'] = merged_result.loc[:, 'num_successes'] * 1.0 / merged_result.loc[:, 'num_eval_trips']
    merged_result.to_csv(os.path.join(SAVE_PATH, 'summary_result_%s.csv' % index), index=False)
    return merged_result

def main():
    merged_result_list = []
    # NEED TO CHANGE FOR FINAL SUBMISSION:
    for i in xrange(100):
        eval_results = run()
        merged_result = evaluation(eval_results, i)
        merged_result_list.append(merged_result.loc[:, ['params', 'success_rate', 'average_time_used_normalized', 'average_total_reward_normalized']])

    all_merged_result = pd.concat(merged_result_list)
    final_performance_across_100simulation_100trips = all_merged_result.groupby('params').mean()
    # NEED TO CHANGE FOR FINAL SUBMISSION:
    final_performance_across_100simulation_100trips.to_csv(os.path.join(SAVE_PATH, 'final_performance_across_100_simulation_last100trips.csv'))

if __name__ == '__main__':
    main()
