export default {
  mounted() {
    console.log('Footer added to DOM', this.el);
    this.observer = new IntersectionObserver(([firstEntry]) => {
      if (firstEntry.isIntersecting) {
        console.log('Loading indicator is visible');
        this.pushEvent('load_more');
      }
    });

    this.observer.observe(this.el);
  },
  updated() {
    const pageNumber = this.el.dataset.pageNumber;
    console.log('Updated', pageNumber);
  },
  destroyed() {
    this.observer.disconnect();
  },
};
