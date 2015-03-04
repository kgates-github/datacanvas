#! /usr/bin/env python

import urllib2, json

sensors = {
	'shanghai': {
		'james': 'ci5c3vgzv000003v4deetujpe',
		'penguin': 'ci4vk908n000h02s7pqy6aud3',
		'WGQ': 'ci4w9izto000302tcgj9hmy9m',
		'frogsh': 'ci4wmzegn000702tcc6dn993o',
		'frasurexu': 'ci4s0caqw000002wey2s695ph',
		'SASPudong': 'ci4xdbcwd000o02tcoi729rb7',
		'transistor': 'ci4xrkkxy000203zz2qz5x2qt',
		'JiadingSensor': 'ci4z8a9d10001032zk4mh5qow',
		'xinchejian': 'ci521nmr600020347n4s107yh',
		'SimonsAllKnowingBox': 'ci521nmr600020347n4s107yh',
		'TheMarms': 'ci527ripa000403471yii8wim',
		'chinotto': 'ci4yd6rfl000a03zzycxw5inl'
	},
	'sanfrancisco': {
		'UrbanLaunchpad': 'ci4yfbbdb000d03zzoq8kjdl0',
		'GlenParklifeLogger': 'ci4yhy9yy000f03zznho5nm7c',
		'ClimateNinja9000': 'ci4yyrdqi000j03zz8ylornqd',
		'Exploratorium': 'ci4vy1tfy000m02s7v29jkkx4',
		'Datavore': 'ci4lnqzte000002xpokc9d25v',
		'GrandTheater': 'ci4usvy81000302s7whpk8qlp',
		'mapsense': 'ci4usvryz000202s7llxjafaf',
		'GehlData': 'ci4xcxxgc000n02tci92gpvi6',
		'a-streetcar-named-data-sensor': 'ci4usss1t000102s7hkg0rpqg',
		'AlleyCat': 'ci4tmxpz8000002w7au38un50',
		'DataDonut': 'ci4yf50s5000c03zzt4h2tnsq',
		'grapealope': 'ci4ut5zu5000402s7g6nihdn0'
	}
}

for city in sensors:
	locations = {}
	f = open('../data/%s-locations.csv' % (city), 'w')
	f.write('lat,lon,name\n')
	print city

	for area in sensors[city]:
		print area
		url = 'http://sensor-api.localdata.com/api/v1/sources/%s/entries?resolution=10m&op=mean&from=2015-02-12T05:00&before=2015-02-12T10:00' % (sensors[city][area])
		req = urllib2.Request(url)
		results = urllib2.urlopen(req)
		
		for sensor in results:
			formatted = json.dumps(json.loads(sensor), sort_keys=True, indent=4, separators=(',', ': '))
			
			if len(json.loads(sensor)['data']):
				for temp in json.loads(sensor)['data']:
					# 0.0158x + 49.184
					locations[sensors[city][area]] = temp['data']['location']
					#print temp['data']['location'], 0.0158 * float(temp['data']['sound']) + 49.184

	for l in locations.keys():
		row = '%s,%s,%s\n' % (locations[l][0], locations[l][1], l)			
		f.write(row)
	f.close()


data = {}
for city in sensors:
	f1 = open('../data/%s-time-location.json' % (city), 'w')
	for area in sensors[city]:
		url = 'http://sensor-api.localdata.com/api/v1/aggregations?each.sources=%s&fields=sound,light&op=mean&from=2015-02-03T04:00:00Z&before=2015-02-03T23:59:00Z&resolution=10m' % (sensors[city][area])
		req = urllib2.Request(url)
		results = urllib2.urlopen(req)
		print url
		for sensor in results:
			elements = json.loads(sensor)
			for d in elements['data']:
				data.setdefault(d['timestamp'], {})
				data[d['timestamp']].setdefault(d['source'], {})
				data[d['timestamp']][d['source']]['sound'] = 0.0158 * float(d['sound']) + 49.184
				data[d['timestamp']][d['source']]['light'] = d['light']
		results.close()	
	
	f1.write(json.dumps(data, sort_keys=True, indent=4, separators=(',', ': ')))
	f1.close()

