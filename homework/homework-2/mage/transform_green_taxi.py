import inflection

if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(data, *args, **kwargs):

    # remove rows where the passenger count is equal to 0 or the trip distance is equal to zero
    data = data[(data['passenger_count']>0) & (data['trip_distance']>0)]

    # create a new column lpep_pickup_date by converting lpep_pickup_datetime to a date
    data['lpep_pickup_date'] = data['lpep_pickup_datetime'].dt.date

    # rename columns in Camel Case to snake_case
    new_columns = []
    camel_case_count=0
    for column_name in data.columns:
        new_column_name = inflection.underscore(column_name)
        new_columns.append(new_column_name)
        if column_name!=new_column_name:
            camel_case_count+=1
    data.columns = new_columns

    print(f'Shape of the data: {data.shape}')
    print(f'Existing values of VendorID: {list(data.vendor_id.unique())}')
    print(f'Number of columns renamed to snake case: {camel_case_count}')

    return data


@test
def test_vendor_id(output, *args):

    # add assertion that vendor_id is one of the existing values in the column
    assert 'vendor_id' in output.columns


@test
def test_passenger_count(output, *args):
    
    # add assertion that passenger_count is greater than 0
    assert min(output['passenger_count']) > 0


@test
def test_trip_distance(output, *args):
    
    # add assertion that trip_distance is greater than 0
    assert min(output['trip_distance']) > 0