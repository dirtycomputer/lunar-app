# FatePair uni-app

The maintained client lives in `uniapp/`. It uses Vue 3 pages, local uni storage, the hosted D1 directory and friend-share endpoints, and the existing chart service. The H5 edition runs directly in a browser. The WeChat target emits WXML, WXSS and JavaScript pages. Android and iOS share the App runtime resources. The older Flutter project remains in the repository for parity checks and existing data formats.

## Build and check

Use Node 24 and npm. From the repository root run the following commands.

```sh
cd uniapp
npm ci
npm test
npm run build
npm run check:build
```

| Target | Development | Build output |
| --- | --- | --- |
| Web | `npm run dev:h5` | `dist/build/h5/` |
| WeChat | `npm run dev:mp-weixin`, import the resulting `dist/dev/mp-weixin` into WeChat DevTools | `dist/build/mp-weixin/` |
| Android and iOS | Import the `uniapp/` CLI project into HBuilderX and select Run on device | `dist/build/app/` contains shared resources. Use HBuilderX to produce signed platform packages. |

Deploy H5 at the root of its domain. The server must serve the H5 index for valid `/s/<public-id>` invitations and preserve the existing D1 API routes. WeChat cards open `/pages/share/index?id=<public-id>`. Both URLs exclude management credentials.

## Application identities

Register a mini program on the WeChat Public Platform. After registration and any required entity verification, open 开发管理 → 开发设置 → 开发者 ID and copy the public AppID. Set the actual service categories and confirm their required materials against the product before submission. Configure the HTTPS request domains for the D1 directory and chart service. Run the official DevTools checks with domain validation enabled and test sharing between two real devices. The development package defaults to WeChat's tourist identifier while no AppID is supplied. [WeChat Public Platform](https://mp.weixin.qq.com/) · [Request domain rules](https://developers.weixin.qq.com/miniprogram/dev/framework/ability/network.html)

Sign in to HBuilderX with the release owner's DCloud account. Open the project's `src/manifest.json`, select 基础配置 and obtain the DCloud AppID for this project. Either enter the public identifiers in the manifest or run the following from `uniapp/`, replacing the example placeholders. The DCloud and WeChat identifiers represent different accounts and applications. [DCloud developer center](https://dev.dcloud.net.cn/) · [DCloud CLI projects](https://uniapp.dcloud.net.cn/quickstart-cli.html) · [App packaging](https://uniapp.dcloud.net.cn/tutorial/build/build-app.html)

```sh
node scripts/configure-ids.mjs --weixin '<your wx app ID>' --dcloud '<your __UNI__ app ID>'
```

Rebuild after configuration. Set up the operator's Android signing key and iOS certificates/provisioning in the private packaging environment. Use HBuilderX 5.34 or a corresponding supported release to build the real APK/AAB and IPA. Verify identity, icons, permissions, local storage after upgrades, device navigation, sharing and recovery on both operating systems. Distribute through the desired stores after their review. The resource archive is not directly installable.

## Continuity

On the same H5 origin the first launch imports the Flutter preferences before removing the old keys. A failed save leaves the original data in place. A device export can be imported on a different platform. Live invitation credentials stay with the device. Existing native installations using Flutter preferences need an explicit data export before switching clients. The new chat always uses the existing server-verified DeepSeek service. Old custom model settings remain portable, without credentials. English and Simplified Chinese cover the primary flow. Other existing locales reuse common translated controls and fall back to English for new material.

The model receives the selected charts only after the user agrees. The service recalculates them with lunar-python. Directory profiles remain fictional and are loaded from a real D1 database. The UTC+8 solar-term boundaries, local clock rules, timezone history and ranking are checked against the server fixtures, original Dart scores and the persisted dataset. Calendar and classical-source tools are under My reading → Chart tools.

The mainland market review and the product's commercial launch gates apply separately to each channel. [Market review](china-market-review.md) · [Release gates](../release/launch.json)

Timezone data is checked in for reproducible builds. With the matching IANA 2026b full TZif distribution including backzone, run `node scripts/pack-zones.cjs` and `python3 scripts/pack-backzone.py /usr/share/zoneinfo` from `uniapp/` to regenerate the two data files. Common localized controls can be regenerated using `python3 scripts/pack-labels.py`.
