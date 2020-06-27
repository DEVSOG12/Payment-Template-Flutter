import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:paystack_manager/paystack_manager.dart';

class TestingPaysyack extends StatefulWidget {
  @override
  _TestingPaysyackState createState() => _TestingPaysyackState();
}

class _TestingPaysyackState extends State<TestingPaysyack> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: CupertinoButton(
            child: Column(
              children: <Widget>[
                Icon(Icons.payment),
                SizedBox(width: 20,),
                Text('Testing New Paystack')

              ],
            ),
            onPressed: () => _processPayment,
          ),
        ),
      ),
      
    );
  }
    void _processPayment() {
    try {

      PaystackPayManager(context: context)
        ..setSecretKey("sk_test_7e3a3dbff5d7b8b2ee7e61125b503ecbba8c850f")
        //accepts widget
        ..setCompanyAssetImage(
          Image(
            image: AssetImage("assets/images/logo.png"),
          )
        )
        ..setAmount(152)
        ..setCurrency("GHS")
        ..setEmail("bakoambrose@gmail.com")
        ..setFirstName("Ambrose")
        ..setLastName("Bako")
        ..setMetadata(
          {
            "custom_fields": [
              {
                "value": "snapTask",
                "display_name": "Payment to",
                "variable_name": "payment_to"
              }
            ]
          },
        )
        ..onSuccesful(_onPaymentSuccessful)
        ..onFailed(_onPaymentFailed)
        ..onCancel(_onPaymentCancelled)
        ..initialize();

    } catch (error) {
      print("Payment Error ==> $error");
    }

  }


  void _onPaymentSuccessful(Transaction transaction){
    print("Transaction was successful");
    print("Transaction Message ===> ${transaction.message}");
    print("Transaction Refrence ===> ${transaction.refrenceNumber}");
  }

  void _onPaymentFailed(Transaction transaction){
    print("Transaction failed");
  }

  void _onPaymentCancelled(Transaction transaction){
    print("Transaction was cancelled");
  }

}