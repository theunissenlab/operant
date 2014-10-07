from __future__ import division
import copy
import numpy as np
import scipy.stats
import pandas as pd
from pecking.base import BaseOperant


class Block(BaseOperant):

    date = property(fget=lambda x: x.session.date)
    percent_stim = property(fget=lambda self: [self.total_no_reward / self.total_pecks,
                            self.total_reward / self.total_pecks])
    percent_interrupt = property(fget=lambda self: [self.no_reward_interrupts / self.total_no_reward,
                                                    self.reward_interrupts / self.total_reward])

    def __init__(self, filename, time, duration, first_peck=None):

        self.stimuli = list()
        self.filename = filename
        self.time = time
        self.first_peck = first_peck
        self.duration = duration
        self.data = None
        self.session = None

    def summary(self):

        columns = ["Time", "Duration", "Total Pecks", "Total No Re", "Total Re", "No Re Interrupts", "Re Interrupts"]
        values = [self.time, self.duration, self.total_pecks, self.total_no_reward, self.total_reward,
                  self.no_reward_interrupts, self.reward_interrupts]

        return columns, values

    def compute_statistics(self):

        if self.data is None:
            return

        self.total_pecks = len(self.data)
        self.total_reward = self.data["class"].sum()
        self.total_no_reward = self.total_pecks - self.total_reward

        new_data = copy.deepcopy(self.data)
        new_data["times"] = new_data.index
        new_data["intervals"] = new_data["times"].diff().fillna(0).astype(np.timedelta64(1, 's'))
        new_data["interrupts"] = map(int, (new_data["intervals"] > 0.19) & (new_data["intervals"] < 6))
        grped = new_data.groupby("class")

        if self.total_no_reward > 0:
            self.no_reward_interrupts = grped.interrupts.sum()[0]
        else:
            self.no_reward_interrupts = 0
        if self.total_reward > 0:
            self.reward_interrupts = grped.interrupts.sum()[1]
        else:
            self.reward_interrupts = 0

        p_interrupt = new_data["interrupts"].mean()
        m = np.diff(self.percent_interrupt)
        v = p_interrupt * (1 - p_interrupt) * (1 / self.total_reward + 1 / self.total_no_reward)
        zscore = m / np.sqrt(v)
        self.binomial_pvalue = 2 * (1 - scipy.stats.norm.cdf(zscore))
        self.is_significant = self.binomial_pvalue <= 0.05




