from pecking.annotations import _check_annotations

class BaseOperant(object):

    def annotate(self, **annotations):

        _check_annotations(annotations)
        self.annotations.update(annotations)

    def save(self):
        pass

    def load(self):
        pass
