export default {
  'chart': {
    'type': 'column'
  },
  'title': {
    'text': 'Daily Power Usage'
  },
  'subtitle': {
    'text': 'Source: Project Duo report'
  },
  'xAxis': {
    'categories': [
      '7/8',
      '7/9',
      '7/10',
      '7/11',
      '7/12',
      '7/13',
      '7/14',
      '7/15',
      '7/16',
      '7/17',
      '7/18',
      '7/19'
    ],
    'crosshair': true
  },
  'yAxis': {
    'min': 0,
    'title': {
      'text': 'Usage (kW/h)'
    }
  },
  'plotOptions': {
    'column': {
      'pointPadding': 0.2,
      'borderWidth': 0
    }
  },
  'series': [
    {
      'name': 'Shenzhen Office',
      'data': [
        49.9,
        71.5,
        106.4,
        129.2,
        144,
        176,
        135.6,
        148.5,
        76.4,
        194.1,
        95.6,
        54.4
      ]
    }
  ]
}
