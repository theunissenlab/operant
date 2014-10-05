from pecking.core.base import BaseOperant


class Experiment(BaseOperant):
    children = ["sessions"]

    num_sessions = property(fget=lambda x: len(x.sessions))

    def __init__(self):

        self.sessions = list()
        self.annotations = dict()
        self.bird = None
        self.start = None
        self.end = None
        self.weight = None

    def summary(self):

        columns = ["Start", "End", "Weight", "Sessions", "Blocks", "Total Pecks", "Signficant Blocks"]
        values = [self.start, self.end, self.weight, self.num_sessions, self.num_blocks, self.total_pecks,
                  self.significant_blocks]

        return columns, values

    @property
    def num_blocks(self):

        num_blocks = 0
        for session in self.sessions:
            num_blocks += session.num_blocks

        return num_blocks

    @property
    def total_pecks(self):

        total_pecks = 0
        for session in self.sessions:
            total_pecks += session.total_pecks

        return total_pecks

    @property
    def significant_blocks(self):

        significant_blocks = 0
        for session in self.sessions:
            significant_blocks += session.significant_blocks

        return significant_blocks
