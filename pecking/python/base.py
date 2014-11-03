import pandas as pd

class BaseOperant(object):

    def save(self):
        pass

    def load(self):
        pass

    def describe(self):
        if hasattr(self, self.children):
            value_list = list()
            for child in getattr(self, self.children):
                columns, values = child.summary()
                value_list.append(values)
            if len(value_list):
                return pd.DataFrame(value_list, columns=columns)

    def summarize(self, objs=list()):

        if len(objs):
            value_list = list()
            for obj in objs:
                columns, values = obj.summary()
                value_list.append(values)
            if len(value_list):
                return pd.DataFrame(value_list, columns=columns)

        else:
            columns, values = self.summary()
            return pd.DataFrame([values], columns=columns)