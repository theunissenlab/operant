from __future__ import division
import copy

import numpy as np
import scipy.stats
import pandas as pd

from pecking.base import BaseOperant


class Block(BaseOperant):

    is_complete = property(fget=lambda self: self.end is not None)

    def __init__(self, name=None, start=None, files=list(), end=None, first_peck=None):

        self.stimuli = list()
        self.name = name
        self.files = files
        self.start = start
        self.first_peck = first_peck
        self.end = end
        self.data = None
        self.session = None

    def summary(self):

        if not hasattr(self, "total_pecks"):
            self.compute_statistics()

        columns = ["Start Time", "End Time", "Total Pecks",
                   "% No Re Interrupts", "% Re Interrupts",
                   "P-Value"]

        values = [self.start.strftime("%H:%M:%S"),
                  self.end.strftime("%H:%M:%S"),
                  self.total_pecks,
                  100 * self.percent_interrupt_no_reward,
                  100 * self.percent_interrupt_reward,
                  self.binomial_pvalue]

        return columns, values

    def compute_statistics(self):

        if self.data is None:
            return

        # Get peck information
        self.total_pecks = len(self.data)
        self.total_stimuli = self.total_pecks
        self.total_reward = self.data["Class"].sum()
        self.total_no_reward = self.total_pecks - self.total_reward

        # Get percentages
        self.percent_reward = self.to_percent(self.total_reward, self.total_stimuli)
        self.percent_no_reward = self.to_percent(self.total_no_reward, self.total_stimuli)

        # Add interval and interrupt data to table
        self.get_interrupts()

        grped = self.data.groupby("Class")

        # Get interruption information
        if self.total_no_reward > 0:
            self.interrupt_no_reward = grped["Interrupts"].sum()[0]
        else:
            self.interrupt_no_reward = 0
        self.percent_interrupt_no_reward = self.to_percent(self.interrupt_no_reward, self.total_no_reward)

        if self.total_reward > 0:
            self.interrupt_reward = grped["Interrupts"].sum()[1]
        else:
            self.interrupt_reward = 0
        self.percent_interrupt_reward = self.to_percent(self.interrupt_reward, self.total_reward)

        self.total_interrupt = self.interrupt_reward + self.interrupt_no_reward
        self.percent_interrupt = self.to_percent(self.total_interrupt, self.total_pecks)

        if (self.total_reward > 0) and (self.total_no_reward > 0):
            mu = (self.percent_interrupt_no_reward - self.percent_interrupt_reward)
            sigma = np.sqrt(self.percent_interrupt * (1 - self.percent_interrupt) * (1 / self.total_reward + 1 / self.total_no_reward))
            self.zscore = mu / sigma
            self.binomial_pvalue = 2 * (1 - scipy.stats.norm.cdf(np.abs(self.zscore)))
            self.is_significant = self.binomial_pvalue <= 0.05
        else:
            self.zscore = 0.0
            self.binomial_pvalue = 1.0
            self.is_significant = False

    @staticmethod
    def to_percent(value, n):

        if n != 0:
            return value / float(n)
        else:
            return 0.0

    def get_interrupts(self):

        if "Interrupts" in self.data:
            return

        time_diff = np.hstack([np.diff([ind.value for ind in self.data.index]), 0]) / 10**9
        inds = (time_diff > 0.19) & (time_diff < 6) # This value should be based on the stimulus duration

        self.data["Interrupts"] = inds
        self.data["Intervals"] = time_diff

