# ShopRite Razorpay Test Server

This local server creates Razorpay Orders with your Test Mode API key secret.
The secret lives in `python_payment_server/razorpay_server_config.py`.

```powershell
.\scripts\start_razorpay_server.ps1
```

Flutter calls this endpoint by default:

```text
http://10.255.104.58:8790/create-order
```

The server binds to `0.0.0.0`, so phones and emulators on the same network can reach it.

```powershell
.\scripts\run_razorpay_android.ps1
```

This is for Test Mode only. Do not use this local server for production.
