from pecking.core.base import BaseOperant


class Bird(BaseOperant):

    children = ["experiments"]
    num_experiments = property(fget=lambda self: len(self.experiments))

    def __init__(self):

        self.name = None
        self.experiments = list()

    def summary(self):

        columns = ["Name", "Experiments", "Avg Pecks Per Block", "% Significant Blocks"]
        values = [self.name, self.num_experiments, self.pecks_per_block, self.significant_blocks]

    @property
    def pecks_per_block(self):

        num_blocks = 0
        num_pecks = 0
        for experiment in self.experiments:
            for session in experiment.sessions:
                for block in session.blocks:
                    num_blocks += 1
                    num_pecks += block.total_pecks

        return float(num_pecks) / num_blocks

    @property
    def significant_blocks(self):

        num_blocks = 0
        num_significant = 0
        for experiment in self.experiments:
            for session in experiment.sessions:
                for block in session.blocks:
                    num_blocks += 1
                    if block.is_significant:
                        num_significant += 1

        return 100 * float(num_significant) / num_blocks
