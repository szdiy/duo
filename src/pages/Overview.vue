<template>
  <div class="index">
    <h1 class="page-header">Dashboard</h1>
  	<div class="row placeholders">
  	  <div class="col-xs-6 col-sm-3 placeholder" v-for="tu of TodayUsage">
  	    <img :src="tu.img" width="200" height="200" class="img-responsive" :alt="tu.title">
  	    <h4>{{tu.title}}</h4>
  	    <span class="text-muted">{{tu.sub}}</span>
  	  </div>
  	</div>

    <h2 class="sub-header">Recent Data</h2>
    <div class="table-responsive">
      <highcharts :options='ChartOption'></highcharts>
    </div>

  	<h2 class="sub-header">Recent Data</h2>
  	<div class="table-responsive">
  	  <table class="table table-striped">
  	    <thead>
  	      <tr>
  	        <th>#</th>
  	        <th>Time</th>
  	        <th>Arrived At</th>
  	        <th>Data Reported</th>
  	      </tr>
  	    </thead>
  	    <tbody>
  	      <tr v-for="r of LastReports">
  	        <td>{{r.id}}</td>
  	        <td>{{r.time}}</td>
  	        <td>{{r.arriveAt}}</td>
  	        <td>{{r.data}}</td>
  	      </tr>
  	    </tbody>
  	  </table>
  	</div>
  </div>
</template>

<script>
import Vue from 'vue'
import VueHighcharts from 'vue-highcharts'
import { getTodayUsage, getWeeksUsage, getLastDayUsage } from '../api/PowerArchiveAPI'
import TodayUsage, { parseOverviewReport } from '../api/TodayUsage'
import ChartOption, { parseChartReport } from '../api/TwoWeekCompare'
import LastReports, { } from '../api/LastReports'

Vue.use(VueHighcharts)

export default {
  name: 'index',
  data () {
    return {
      TodayUsage,
      ChartOption,
      LastReports
    }
  },
  created: function () {
    return Promise.all([getTodayUsage, getLastDayUsage, getWeeksUsage])
      .then((todayResponse, twoDaysResponse, getWeeksUsage) => {
        // update report data here...

      })
  }
}
</script>

<style>
</style>
