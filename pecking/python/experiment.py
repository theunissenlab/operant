from pecking.base import BaseOperant


class Experiment(BaseOperant):
    children = "sessions"

    num_sessions = property(fget=lambda x: len(x.sessions))

    def __init__(self, name= None, start=None, end=None, weight=None, fast_start=None):

        self.sessions = list()
        self.bird = None
        self.name = name
        self.start = start
        self.end = end
        self.fast_start = fast_start
        self.weight = weight

    def summary(self):

        columns = ["Start", "End", "Weight", "Sessions", "Blocks",
                   "Avg. Pecks", "Signficant Blocks"]
        if self.end is not None:
            end = self.end.strftime("%m/%d/%y")
        else:
            end = None
        values = [self.start.strftime("%m/%d/%y"),
                  end,
                  self.weight,
                  self.num_sessions, self.num_blocks,
                  self.total_pecks / float(self.num_blocks),
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
