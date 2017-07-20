<template>
  <div class="nav-left" id="nav-left">
    <ul class="nav nav-sidebar">
      <li v-for="r of routes" :name="r.name"><a :href="'#'+r.path">{{r.name}}</a></li>
    </ul>
  </div>
</template>

<script>
import router from '../router'

export default {
  name: 'navleft',
  data () {
    return {
      routes: router.options.routes,
      cur: location.hash.replace('#', '')
    }
  }
}
</script>