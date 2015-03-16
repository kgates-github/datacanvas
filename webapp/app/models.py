import json
import pandas as pd


def load_cities():
    df = pd.read_csv('data/cities.csv', parse_dates=['timestamp'])
    df.set_index('timestamp', inplace=True)
    df['hour'] = df.index.hour
    df['month'] = df.index.month
    df['date'] = df.index.date
    df['year'] = df.index.year
    df['YearMonth'] = df.index.map(lambda x: str(x.year) + '-' + ('0' + str(x.month))[-2:] + '-02')
    return df


def get_metric_data(df, city, metric, date_from, date_to, group_col='hour'):
    chart_name = {}
    chart_name['hour'] = 'time_of_day'
    chart_name['YearMonth'] = 'month'
    data_df = df[df.city == city][date_from:date_to]
    result = data_df.groupby(group_col)[metric].mean()
    json_data = result.to_json(date_format='iso', orient='split')
    json_data = json.loads(json_data)
    json_data['city'] = city
    json_data['chart'] = chart_name.get(group_col, group_col)
    data = []
    for dt, val in zip(json_data['index'], json_data['data']):
        data.append({'time': dt, 'value': val})
    json_data['data'] = data
    # Remove the index col
    del json_data['index']
    return json_data
