from sklearn.datasets import make_regression
from pathlib import Path
import pandas
import numpy


def generate_dataset(number_rows, number_columns):
    x, y = make_regression(n_samples=number_rows, n_features=number_columns, random_state=0, noise=10)
    return list([(numpy.append(ex, ey)) for ex, ey in zip(x, y)])


def write_dataset_to_disk(dataset, dataset_name):
    df = pandas.DataFrame(dataset)
    current_dir = Path(__file__).resolve().parent
    path = current_dir / dataset_name
    df.to_csv(path, index=False, header=False)


def run_dataset_generation(n_rows, n_columns, file_name):
    print('Starting generating dataset (', n_rows, ' rows x ', n_columns, ' columns )')
    dataset = generate_dataset(n_rows, n_columns)
    write_dataset_to_disk(dataset, file_name)
    print('Finished dataset (', n_rows, ' rows x ', n_columns, ' columns )', 'generation')


# run_dataset_generation(20000, 5, 'tiny_dataset.csv')

# run_dataset_generation(200000, 5, 'tiny_ten_times_larger_dataset.csv')

# run_dataset_generation(1000000, 5, 'tiny_fifty_times_larger_dataset.csv')

run_dataset_generation(2000000, 5, 'tiny_one_hundred_times_larger_dataset.csv')

# run_dataset_generation(10000000, 5, 'tiny_five_hundred_times_larger_dataset.csv')

# run_dataset_generation(20000000, 5, 'tiny_one_thousand_times_larger_dataset.csv')