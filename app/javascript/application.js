// Entry point for the build script in your package.json

import * as Sentry from '@sentry/browser';
import { BrowserTracing } from '@sentry/tracing';

import '@hotwired/turbo-rails';
import './controllers';
import 'bootstrap';

Sentry.init({
  dsn: 'https://92aa3f17a3bd4526b698472f65ec2ab0@o4504181930721280.ingest.sentry.io/4505331441270784',

  integrations: [new BrowserTracing()],

  tracesSampleRate: 1.0,
});
