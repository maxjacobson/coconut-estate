import Component from '@ember/component';

export default Component.extend({
  actions: {
    destroy(roadmap) {
      if (confirm("Are you sure?")) {
        alert(`I'd love to destroy ${roadmap.name}, but I don't know how`);
      }
    }
  },
});
