from sklearn.base import TransformerMixin

class ColumnSelector(TransformerMixin):
	"Column extractor for use in pipeline"

	def __init__(self, columns):
		self.columns = columns

	def fit(self, X, y=None):
		return self

	def transform(self, X, y=None):
		return X[self.columns]