import Vue from 'vue'
import Router from 'vue-router'
import Overview from '@/pages/Overview'
import Reports from '@/pages/Reports'
import Analytics from '@/pages/Analytics'
import Export from '@/pages/Export'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Overview',
      component: Overview
    },
    {
      path: '/reports',
      name: 'Reports',
      component: Reports
    },
    {
      path: '/analytics',
      name: 'Analytics',
      component: Analytics
    },
    {
      path: '/export',
      name: 'Export',
      component: Export
    }
  ]
})
