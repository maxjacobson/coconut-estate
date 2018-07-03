import Route from '@ember/routing/route';
import Ember from 'ember';

export default Route.extend({
  beforeModel() {
    Ember.Logger.warn(`Unknown route ${location.pathname}, displaying 404 page.`);
  }
});
