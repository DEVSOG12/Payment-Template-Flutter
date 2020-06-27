// import 'dart:js';

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/cupertino.dart';

// Add Paystack Public Keyy
String paystackPublicKey = '{YOUR_PAYSTACK_PUBLIC_KEY}';
final _scaffoldKey = new GlobalKey<ScaffoldState>();
bool isGeneratingCode = false;
CheckoutMethod _method;
var banks = ['Bank', 'Card'];
CheckoutMethod _parseStringToMethod(String string) {
  CheckoutMethod method = CheckoutMethod.selectable;
  switch (string) {
    case 'Bank':
      method = CheckoutMethod.bank;
      break;
    case 'Card':
      method = CheckoutMethod.card;
      break;
  }
  return method;
}

class PaystackPay extends StatefulWidget {
  @override
  _PaystackPayState createState() => _PaystackPayState();
}

class _PaystackPayState extends State<PaystackPay> {
  @override
  void initState() {
    PaystackPlugin.initialize(publicKey: paystackPublicKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Column(children: <Widget>[
        DropdownButtonHideUnderline(
          child: InputDecorator(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
              hintText: 'Checkout method',
            ),
            isEmpty: _method == null,
            child: new DropdownButton<CheckoutMethod>(
              value: _method,
              isDense: true,
              onChanged: (CheckoutMethod value) {
                setState(() {
                  _method = value;
                });
              },
              items: banks.map((String value) {
                return new DropdownMenuItem<CheckoutMethod>(
                  value: _parseStringToMethod(value),
                  child: new Text(value),
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(
          height: 40,
        ),
        _getPlatformButton('Paystack', () => null)
      ]),
    ));
  }
  createAccessCode() async {
  //TODO Add Scret kEy //TODO
 String ski = 'sk_test_ddce9ccf26b912c5273e8ff2244fdbaa3378f374';
  Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $ski'
  };
  Map data = {"amount": 1000000, "email": 'myController.text'};
  String payload = json.encode(data);
  http.Response response = await http.post(
      'https://api.paystack.co/transaction/initialize',
      headers: headers,
      body: payload);
      print(response.body);
  return jsonDecode(response.body);
}

  chargeCard() async {
    if (_method == null) {
      _showMessage('Select checkout method first');
      return;
    }
    setState(() {
      isGeneratingCode = !isGeneratingCode;
    });

    Map accessCode = await createAccessCode();

    setState(() {
      isGeneratingCode = !isGeneratingCode;
    });

    Charge charge = Charge()
      ..amount = 1000000
      ..accessCode = accessCode["data"]["access_code"]
      ..email = "myController.text;";

    CheckoutResponse response = await PaystackPlugin.checkout(
      context,
      method: _method,
      charge: charge,
      fullscreen: false,
//         logo: new InitialNameAvatar(
//     'John Doe',
//     circleAvatar: true,
//     borderColor: Colors.grey,
//     borderSize: 4.0,
//     backgroundColor: Colors.blue,
//     foregroundColor: Colors.white,
//     padding: 20.0,
//     textSize: 30.0,
// ),
    );
    if (response.status == true) {
      // Navigator.push(context,  PageTransition(  type: PageTransitionType.leftToRight,child: AfterLogin(token: token,)));
    } else {
      _showErrorDialog();
    }
  }


 void _showErrorDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return errorDialog(context);
      },
    );
  }
}
 Dialog errorDialog(context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0)), //this right here
      child: Container(
        height: 350.0,
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.cancel,
                color: Colors.red,
                size: 90,
              ),
              SizedBox(height: 15),
              Text(
                'Failed to process payment',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              Text(
                "Error in processing payment, please try again",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
Widget _getPlatformButton(String string, Function() function) {
  // is still in progress
  Widget widget;
  if (Platform.isIOS) {
    widget = CupertinoButton(
      child: Text(
        'Paystack',
        style: TextStyle(color: Colors.blue),
      ),
      onPressed: function,
    );
  } else {
    widget = new RaisedButton(
      onPressed: function,
      color: Colors.blueAccent,
      textColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
      child: new Text(
        string.toUpperCase(),
        style: const TextStyle(fontSize: 17.0),
      ),
    );
  }
  return widget;
}

_showMessage(String message,
      [Duration duration = const Duration(seconds: 4)]) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: new Text(message),
      duration: duration,
      action: new SnackBarAction(
          label: 'CLOSE',
          onPressed: () => _scaffoldKey.currentState.removeCurrentSnackBar()),
    ));
  }
