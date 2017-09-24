import Vue from 'vue'
import VueResource from 'vue-resource'
import { API_HOST, DEFAULT_NODE } from '../constants'
import $ from 'jquery'
Vue.use(VueResource)

const Period = {
  LAST_24HOURS: '24hours',
  LAST_48HOURS: '48hours',
  LAST_7DAYS: '7days',
  LAST_30DAYS: '1month',
  LAST_60DAYS: '2months',
  LAST_90DAYS: '3months'
}

const baseOptions = {
  url: API_HOST + '/duo/device/',
  period: Period.LAST_24HOURS,
  nodeId: DEFAULT_NODE
}

// TODO: add nodeId as parameter
export function getPowerArchive (period) {
  const { url, nodeId } = baseOptions
  return $.get(url + nodeId + '/power?period=' + (period || baseOptions.period))
}

export function get24Hours () {
  return getPowerArchive(Period.LAST_24HOURS)
}

export function get48Hours () {
  return getPowerArchive(Period.LAST_48HOURS)
}

export function get7Days () {
  return getPowerArchive(Period.LAST_7DAYS)
}

export function get30Days () {
  return getPowerArchive(Period.LAST_30DAYS)
}

export function get60Days () {
  return getPowerArchive(Period.LAST_60DAYS)
}

export function get90Days () {
  return getPowerArchive(Period.LAST_90DAYS)
}

//
// export default {
//   name: 'index',
//   data () {
//     return {
//       url: API_HOST + '/duo/device/',
//       period: '2months',
//       nodeId: DEFAULT_NODE,
//       todayUsage: 0,
//       lastdayUsage: 0,
//       thisWeekUsage: 0,
//       thisMonthUsage: 0,
//       options: {
//         'chart': {'type': 'column'},
//         'title': {'text': 'Daily Power Usage'},
//         'subtitle': {'text': 'Source: Project Duo report'},
//         'xAxis': {
//           'categories': [],
//           'crosshair': true},
//         'yAxis': {'min': 0, 'title': {'text': 'Usage (kW/h)'}},
//         'plotOptions': {'column': {'pointPadding': 0.2, 'borderWidth': 0}},
//         'series': [{'name': 'Shenzhen Office', 'data': []}]
//       }
//     }
//   },
//   methods: {
//     getWeeksUsage: function () {
//       this.$http.get(this.url + this.nodeId + '/power?' + 'period=' + this.period)
//         .then(response => {
//           // console.log(response.data)
//           var count
//           // console.log(response.data)
//           for (count = 0; count < response.data.length; count++) {
//             var dayUsage = []
//             var arcCount
//             for (arcCount = 0; arcCount < response.data[count].archive_json.length; arcCount++) {
//               dayUsage.push(Number(response.data[count].archive_json[arcCount].total))
//             }
//             if (isNaN(Math.max(dayUsage))) {
//               this.options.series[0].data.push(0)
//               console.log(0)
//             } else {
//               this.options.series[0].data.push(Math.max(dayUsage) - Math.min(dayUsage))
//               // console.log(Math.max(dayUsage) - Math.min(dayUsage))
//             }
//             // console.log(dayUsage)
//             // this.option.series.data.push()
//             this.options.xAxis.categories.push(response.data[count].date)
//           }
//           // console.log(this.options.series[0].data)
//           // console.log(this.options.xAxis.categories)
//         })
//     },
//     calculateUsage: function (data) {
//       var usage = []
//       var count
//       for (count = 0; count < data.length; count++) {
//         var arcCount
//         for (arcCount = 0; arcCount < data[count].archive_json.length; arcCount++) {
//           usage.push(Number(data[count].archive_json[arcCount].total))
//         }
//       }
//       if (isNaN(Math.max(usage))) {
//         return 0
//       } else {
//         return Math.max(usage) - Math.min(usage)
//       }
//     },
//     getTodayUsage: function () {
//       this.$http.get(this.url + this.nodeId + '/power?' + 'period=' + '24hours')
//         .then(response => {
//           this.todayUsage = this.calculateUsage(response.data)
//         })
//     },
//     getLastDayUsage: function () {
//       this.$http.get(this.url + this.nodeId + '/power?' + 'period=' + '48hours')
//         .then(response => {
//           this.lastdayUsage = this.calculateUsage(response.data) - this.todayUsage
//         })
//     },
//     getThisWeekUsage: function () {
//       this.$http.get(this.url + this.nodeId + '/power?' + 'period=' + '7days')
//         .then(response => {
//           this.thisWeekUsage = this.calculateUsage(response.data)
//         })
//     },
//     getThisMonthUsage: function () {
//       this.$http.get(this.url + this.nodeId + '/power?' + 'period=' + '1month')
//         .then(response => {
//           this.thisMonthUsage = this.calculateUsage(response.data)
//         })
//     }
//   },
//   created: function () {
//     this.getWeeksUsage()
//     this.getTodayUsage()
//     this.getLastDayUsage()
//     this.getThisWeekUsage()
//     this.getThisMonthUsage()
//   }
// }
