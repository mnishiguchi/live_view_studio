export default {
  mounted() {
    console.log('mounted', this.el);

    // https://flatpickr.js.org/instance-methods-properties-elements/
    // https://flatpickr.js.org/options/
    this.flatpickrInstance = flatpickr(this.el, {
      enableTime: false,
      dateFormat: 'F d, Y',
      onChange: (selectedDates, dateStr, instance) => {
        this.pushPickedDate(dateStr);
      },
    });
  },
  updated() {
    console.log('updated', this.el);
  },
  destroyed() {
    console.log('destroyed', this.el);
    this.flatpickrInstance.destroy();
  },
  pushPickedDate(date) {
    this.pushEvent('date_picker:picked', { date });
  },
};
