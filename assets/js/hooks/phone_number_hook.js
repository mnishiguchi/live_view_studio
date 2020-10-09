import { AsYouType } from 'libphonenumber-js';

export default {
  mounted() {
    console.log('mounted', this.el);
    this.el.addEventListener('input', (e) => {
      // https://gitlab.com/catamphetamine/libphonenumber-js#as-you-type-formatter
      e.target.value = new AsYouType('US').input(e.target.value)
    });
  },
};
