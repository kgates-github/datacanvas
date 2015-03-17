import json
import pandas as pd


def load_cities_data():
    df = pd.read_csv('data/cities.csv', parse_dates=['timestamp'])
    df.set_index('timestamp', inplace=True)
    df['hour'] = df.index.hour.astype(str)
    df['hour'] = '0' + df['hour']
    df['hour'] = df.hour.str.slice(-2)
    df['month'] = df.index.month.astype(str)
    df['month'] = '0' + df['month']
    df['month'] = df.month.str.slice(-2)
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


def get_ts_data(df, city, metric, date_from, date_to, group_col='date'):
    data_df = df[df.city == city][date_from:date_to]
    quantile = {}
    quantile[0.0] = 'min'
    quantile[0.25] = 'lower'
    quantile[0.50] = 'median'
    quantile[0.75] = 'upper'
    quantile[1.0] = 'max'
    json_data = {}
    json_data['city'] = city
    json_data['date_from'] = date_from
    json_data['chart'] = 'timeseries'
    json_data['date_to'] = date_to
    json_data['dimension'] = metric
    metric_data = data_df.groupby(group_col)[metric].quantile([0.0, 0.25, 0.5, 0.75, 1.0])
    data = []
    for dt, rows in metric_data.unstack(1).iterrows():
        row_data = {}
        row_data['date'] = dt.strftime('%Y-%m-%d')
        for idx, val in zip(rows.index, rows):
            row_data[quantile[idx]] = round(val, 2)
        data.append(row_data)
    json_data['data'] = data
    return json_data


def get_city_agg_data(df, metric, date_from, date_to, group_col='city'):
    data_df = df[date_from:date_to]
    quantile = {}
    quantile[0.0] = 'min'
    quantile[0.25] = 'lower'
    quantile[0.50] = 'median'
    quantile[0.75] = 'upper'
    quantile[1.0] = 'max'
    json_data = {}
    json_data['date_from'] = date_from
    json_data['chart'] = 'ranking'
    json_data['date_to'] = date_to
    json_data['dimension'] = metric
    metric_data = data_df.groupby(group_col)[metric].quantile([0.0, 0.25, 0.5, 0.75, 1.0])
    data = []
    for city, rows in metric_data.unstack(1).iterrows():
        row_data = {}
        row_data['city'] = city
        for idx, val in zip(rows.index, rows):
            row_data[quantile[idx]] = round(val, 2)
        data.append(row_data)
    json_data['data'] = data
    return json_data
