from __future__ import division
from pecking.base import BaseOperant


class Bird(BaseOperant):

    children = "experiments"
    num_experiments = property(fget=lambda self: len(self.experiments))

    def __init__(self, name):

        self.name = name
        self.experiments = list()

    def summary(self):

        columns = ["Name", "Experiments", "Avg Pecks Per Block", "% Significant Blocks"]
        values = [self.name, self.num_experiments, self.pecks_per_block, self.significant_blocks]

        return columns, values

    @property
    def pecks_per_block(self):

        num_blocks = 0
        num_pecks = 0
        for experiment in self.experiments:
            num_blocks += experiment.num_blocks
            num_pecks += experiment.total_pecks

        return float(num_pecks) / num_blocks

    @property
    def significant_blocks(self):

        num_blocks = 0
        num_significant = 0
        for experiment in self.experiments:
            num_blocks += experiment.num_blocks
            num_significant += experiment.significant_blocks

        return 100 * float(num_significant) / num_blocks
