import { Application } from '@hotwired/stimulus';

const application = Application.start();

// Configure Stimulus development experience
application.debug = false;
// eslint-disable-next-line no-undef
window.Stimulus = application;

export default application;
