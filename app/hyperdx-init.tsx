'use client';

import { useEffect } from 'react';
import { APP_VERSION } from '../src/config/version';

let initialized = false;

export default function HyperDXInit() {
  useEffect(() => {
    if (initialized) return;

    const init = async () => {
      try {
        const res = await fetch('/api/rum-config', { cache: 'no-store' });
        if (!res.ok) return;

        const { apiKey, url, service } = await res.json();
        if (!apiKey) return;

        initialized = true;

        const HyperDX = (await import('@hyperdx/browser')).default;
        HyperDX.init({
          apiKey,
          url,
          service,
          tracePropagationTargets: [/us\.makgol\.com/i, /we\.makgol\.com/i],
          consoleCapture: true,
          advancedNetworkCapture: false,
          maskAllInputs: true,
          instrumentations: { webvitals: true },
          otelResourceAttributes: {
            'app.version': APP_VERSION.version,
            'deployment.environment': 'hub',
          },
        });
      } catch {
        // RUM 초기화 실패는 서비스 동작에 영향을 주지 않아야 하므로 조용히 무시한다
      }
    };

    init();
  }, []);

  return null;
}
