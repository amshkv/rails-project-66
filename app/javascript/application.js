// Entry point for the build script in your package.json

import * as Sentry from '@sentry/browser';
import { BrowserTracing } from '@sentry/tracing';

import '@hotwired/turbo-rails';
import './controllers';
import 'bootstrap';

Sentry.init({
  dsn: 'https://74544f2f86c843499211e100657dd5ce@o4504181930721280.ingest.sentry.io/4505579489394688',

  integrations: [new BrowserTracing()],

  tracesSampleRate: 1.0,
});
