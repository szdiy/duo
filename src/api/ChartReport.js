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

import moment from 'moment'
/*
  Required API:
    ?period=2months

  Return two series of data:
  dateSeries: [<date_str>],
  dataSeries: [<reading>]
}
 */
export function parseChartReport (oneMonthSimpleList) {
  if (oneMonthSimpleList.length >= 2) {
    const startDate = moment(oneMonthSimpleList[0].date)
    const endDate = moment(oneMonthSimpleList[oneMonthSimpleList.length - 1].date)

    const days = endDate.diff(startDate, 'days')
    const dateSeries = []
    const dataSeries = []
    const dateRecords = oneMonthSimpleList.reduce((sum, dayRecord) => {
      sum[dayRecord.date] = dayRecord.simple.total
      return sum
    }, {})

    let baseValue = dateRecords[startDate.format('YYYY-MM-DD')]
    for (let i = 1; i < days; i++) {
      var currentDate = moment(startDate).add(i, 'd').format('YYYY-MM-DD')
      dateSeries.push(currentDate)
      var currentValue = dateRecords[currentDate] || 0
      if (currentValue) {
        dataSeries.push(currentValue - baseValue)
        baseValue = currentValue
      } else {
        dataSeries.push(0)
      }
    }

    // const dateSeries = oneMonthSimpleList.map((day) => day.date)
    // const dataSeries = oneMonthSimpleList.map((day) => day.simple.total)

    return {
      dateSeries,
      dataSeries
    }
  }

  return {
    dateSeries: [],
    dataSeries: []
  }
}
