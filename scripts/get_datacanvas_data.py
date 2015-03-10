import sys
import datetime
import requests
import pandas as pd


def get_datacanvas(from_dt, before_dt, city=None, sensor=None, metric='mean', resolution='1h'):
    api_url = 'http://sensor-api.localdata.com/api/v1/aggregations'
    api_params = {}
    if sensor:
        api_params['each.sources'] = sensor
    else:
        api_params['over.city'] = city
    api_params['op'] = metric
    api_params['fields'] = 'temperature,light,airquality_raw,sound,humidity,dust'
    api_params['resolution'] = resolution
    api_params['from'] = from_dt
    api_params['before'] = before_dt
    resp = requests.get(api_url, params=api_params)
    raw_json = resp.json()
    raw_json = raw_json['data']
    return pd.DataFrame(raw_json)


def get_sensor_data(start_dt, end_dt, city, sensor_name=None, sensor_id=None, metric='mean', resolution='1h'):
    print city, sensor_name
    
    def date_ranges(start, end, delta):
        curr = start
        while curr < end:
            next_curr = curr + delta
            yield curr, next_curr
            curr = next_curr

    data_df = None
    yr, mon, day = map(int, start_dt.split('-'))
    start_dt = datetime.date(yr, mon, day)
    yr, mon, day = map(int, end_dt.split('-'))
    end_dt = datetime.date(yr, mon, day)

    for from_dt, before_dt in date_ranges(start_dt, end_dt, datetime.timedelta(days=2)):
        df = get_datacanvas(from_dt, before_dt, city=city, sensor=sensor_id, metric=metric, resolution=resolution)
        if city and 'city' not in df.columns:
            df['city'] = city
        if sensor_name:
            df['sensor_name'] = sensor_name
        if sensor_id:
            df['sensor_id'] = sensor_id
        if data_df is None:
            data_df = df
        else:
            data_df = data_df.append(df)
    return df


def extract_sensor_data(sensor_filename, download_folder, begin_dt, end_dt, metric='mean', resolution='30m'):
    sensors_df = pd.read_csv(sensor_filename)
    for _, row in sensors_df.iterrows():
        data_df = get_sensor_data(begin_dt, end_dt, row['City'], row['Name'], row['Id'], metric, resolution=resolution)
        dn_filename = download_folder + row['City'] + '_' + row['Name'] + '_' + begin_dt + '_' + end_dt + '_' + metric + '_' + resolution + '.csv'
        data_df.to_csv(dn_filename, index=False)


if __name__ == '__main__':
    if len(sys.argv) < 6:
        print "Need arguments data_folder, begin_dt, end_dt, metric, resolution"
        print "python get_datacanvas_data.py '../data/' '2015-02-15' '2015-02-17' 'mean' '1h'"
        print "For example: '..data/' '2015-02-01', '2015-02-10', 'mean', '1h'"
        sys.exit(0)
    _, data_folder, begin_dt, end_dt, metric, resolution = sys.argv
    extract_sensor_data(data_folder + 'sensor_ids.csv', data_folder + 'datacanvas/', begin_dt, end_dt, metric, resolution)
