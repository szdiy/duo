<template>
  <div class="index">
    <h1 class="page-header">Dashboard</h1>

    <div class="row placeholders">
      <div class="col-xs-6 col-sm-3 placeholder">
        <img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" width="200" height="200" class="img-responsive" alt="Generic placeholder thumbnail">
        <h4>今日用电</h4>
        <span class="text-muted">Something else</span>
      </div>
      <div class="col-xs-6 col-sm-3 placeholder">
        <img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" width="200" height="200" class="img-responsive" alt="Generic placeholder thumbnail">
        <h4>昨日用电</h4>
        <span class="text-muted">Something else</span>
      </div>
      <div class="col-xs-6 col-sm-3 placeholder">
        <img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" width="200" height="200" class="img-responsive" alt="Generic placeholder thumbnail">
        <h4>本周用电</h4>
        <span class="text-muted">Something else</span>
      </div>
      <div class="col-xs-6 col-sm-3 placeholder">
        <img src="data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==" width="200" height="200" class="img-responsive" alt="Generic placeholder thumbnail">
        <h4>本月用电</h4>
        <span class="text-muted">Something else</span>
      </div>
    </div>

    <h2 class="sub-header">Recent Data</h2>
    <div class="table-responsive">
      <highcharts :options='options'></highcharts>
    </div>

    <h2 class="sub-header">Recent Data</h2>
    <div class="table-responsive">
      <table class="table table-striped">
        <thead>
          <tr>
            <th>#</th>
            <th>Header</th>
            <th>Header</th>
            <th>Header</th>
            <th>Header</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>1,001</td>
            <td>Lorem</td>
            <td>ipsum</td>
            <td>dolor</td>
            <td>sit</td>
          </tr>
          <tr>
            <td>1,002</td>
            <td>amet</td>
            <td>consectetur</td>
            <td>adipiscing</td>
            <td>elit</td>
          </tr>
          <tr>
            <td>1,003</td>
            <td>Integer</td>
            <td>nec</td>
            <td>odio</td>
            <td>Praesent</td>
          </tr>
          <tr>
            <td>1,003</td>
            <td>libero</td>
            <td>Sed</td>
            <td>cursus</td>
            <td>ante</td>
          </tr>
          <tr>
            <td>1,004</td>
            <td>dapibus</td>
            <td>diam</td>
            <td>Sed</td>
            <td>nisi</td>
          </tr>
          <tr>
            <td>1,005</td>
            <td>Nulla</td>
            <td>quis</td>
            <td>sem</td>
            <td>at</td>
          </tr>
          <tr>
            <td>1,006</td>
            <td>nibh</td>
            <td>elementum</td>
            <td>imperdiet</td>
            <td>Duis</td>
          </tr>
          <tr>
            <td>1,007</td>
            <td>sagittis</td>
            <td>ipsum</td>
            <td>Praesent</td>
            <td>mauris</td>
          </tr>
          <tr>
            <td>1,008</td>
            <td>Fusce</td>
            <td>nec</td>
            <td>tellus</td>
            <td>sed</td>
          </tr>
          <tr>
            <td>1,009</td>
            <td>augue</td>
            <td>semper</td>
            <td>porta</td>
            <td>Mauris</td>
          </tr>
          <tr>
            <td>1,010</td>
            <td>massa</td>
            <td>Vestibulum</td>
            <td>lacinia</td>
            <td>arcu</td>
          </tr>
          <tr>
            <td>1,011</td>
            <td>eget</td>
            <td>nulla</td>
            <td>Class</td>
            <td>aptent</td>
          </tr>
          <tr>
            <td>1,012</td>
            <td>taciti</td>
            <td>sociosqu</td>
            <td>ad</td>
            <td>litora</td>
          </tr>
          <tr>
            <td>1,013</td>
            <td>torquent</td>
            <td>per</td>
            <td>conubia</td>
            <td>nostra</td>
          </tr>
          <tr>
            <td>1,014</td>
            <td>per</td>
            <td>inceptos</td>
            <td>himenaeos</td>
            <td>Curabitur</td>
          </tr>
          <tr>
            <td>1,015</td>
            <td>sodales</td>
            <td>ligula</td>
            <td>in</td>
            <td>libero</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import Vue from 'vue'
import VueHighcharts from 'vue-highcharts'
import VueResource from 'vue-resource'
import { API_HOST, DEFAULT_NODE } from '../constants'
Vue.use(VueResource)
Vue.use(VueHighcharts)

export default {
  name: 'index',
  data () {
    return {
      url: API_HOST + '/duo/device/',
      period: '2months',
      node_id: DEFAULT_NODE,
      todayUsage: 0,
      lastdayUsage: 0,
      thisWeekUsage: 0,
      thisMonthUsage: 0,
      options: {
        'chart': {'type': 'column'},
        'title': {'text': 'Daily Power Usage'},
        'subtitle': {'text': 'Source: Project Duo report'},
        'xAxis': {
          'categories': [],
          'crosshair': true},
        'yAxis': {'min': 0, 'title': {'text': 'Usage (kW/h)'}},
        'plotOptions': {'column': {'pointPadding': 0.2, 'borderWidth': 0}},
        'series': [{'name': 'Shenzhen Office', 'data': []}]
      }
    }
  },
  methods: {
    getWeeksUsage: function () {
      this.$http.get(this.url + this.node_id + '/power?' + 'period=' + this.period)
        .then(response => {
          // console.log(response.data)
          var count
          // console.log(response.data)
          for (count = 0; count < response.data.length; count++) {
            var dayUsage = []
            var arcCount
            for (arcCount = 0; arcCount < response.data[count].archive_json.length; arcCount++) {
              dayUsage.push(Number(response.data[count].archive_json[arcCount].total))
            }
            if (isNaN(Math.max(dayUsage))) {
              this.options.series[0].data.push(0)
              console.log(0)
            } else {
              this.options.series[0].data.push(Math.max(dayUsage) - Math.min(dayUsage))
              // console.log(Math.max(dayUsage) - Math.min(dayUsage))
            }
            // console.log(dayUsage)
            // this.option.series.data.push()
            this.options.xAxis.categories.push(response.data[count].date)
          }
          // console.log(this.options.series[0].data)
          // console.log(this.options.xAxis.categories)
        })
    },
    calculateUsage: function (data) {
      var usage = []
      var count
      for (count = 0; count < data.length; count++) {
        var arcCount
        for (arcCount = 0; arcCount < data[count].archive_json.length; arcCount++) {
          usage.push(Number(data[count].archive_json[arcCount].total))
        }
      }
      if (isNaN(Math.max(usage))) {
        return 0
      } else {
        return Math.max(usage) - Math.min(usage)
      }
    },
    getTodayUsage: function () {
      this.$http.get(this.url + this.node_id + '/power?' + 'period=' + '24hours')
        .then(response => {
          this.todayUsage = this.calculateUsage(response.data)
        })
    },
    getLastDayUsage: function () {
      this.$http.get(this.url + this.node_id + '/power?' + 'period=' + '48hours')
        .then(response => {
          this.lastdayUsage = this.calculateUsage(response.data) - this.todayUsage
        })
    },
    getThisWeekUsage: function () {
      this.$http.get(this.url + this.node_id + '/power?' + 'period=' + '7days')
        .then(response => {
          this.thisWeekUsage = this.calculateUsage(response.data)
        })
    },
    getThisMonthUsage: function () {
      this.$http.get(this.url + this.node_id + '/power?' + 'period=' + '1month')
        .then(response => {
          this.thisMonthUsage = this.calculateUsage(response.data)
        })
    }

  },
  created: function () {
    this.getWeeksUsage()
    this.getTodayUsage()
    this.getLastDayUsage()
    this.getThisWeekUsage()
    this.getThisMonthUsage()
  }
}
</script>

<style>
</style>
