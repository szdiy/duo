import Vue from 'vue'
import App from './App'
import router from './router'
import jQuery from 'jquery'
import 'bootstrap/dist/css/bootstrap.css'
import './assets/app.css'

Vue.config.productionTip = false

/* eslint-disable no-new */
const vm = new Vue({
  el: '#app',
  router,
  render: h => h(App)
})
vm.$router.beforeEach((to, from, next) => {
  const t = jQuery('#nav-left li[name=' + to.name + ']')
  const f = jQuery('#nav-left li[name=' + from.name + ']')
  t.addClass('active')
  f.removeClass('active')
  next()
})

