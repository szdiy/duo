<template>
  <div id="app">
    <NavTop></NavTop>
    <div class="container-fluid">
      <div class="row">
        <div class="col-sm-3 col-md-2 sidebar">
          <NavLeft></NavLeft>
        </div>
        <div class="col-sm-9 col-sm-offset-3 col-md-10 col-md-offset-2 main">
          <router-view></router-view>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import NavLeft from './components/NavLeft'
import NavTop from './components/NavTop'
export default {
  name: 'app',
  components: {
    NavTop,
    NavLeft
  }
}
</script>

