// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/api_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'donation_history_screen.dart';
import '../../utils/image_helper.dart';
import '../../utils/env_config.dart';
import '../../utils/app_localizations.dart';

class CharityDonationScreen extends StatefulWidget {
  final Map<String, dynamic> charity;

  const CharityDonationScreen({
    super.key,
    required this.charity,
  });

  @override
  State<CharityDonationScreen> createState() => _CharityDonationScreenState();
}

class _CharityDonationScreenState extends State<CharityDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _panCardController = TextEditingController();
  final _apiService = ApiService();
  late Razorpay _razorpay;
  late AppLocalizations localizations;

  String _paymentMethod = 'UPI';
  bool _requestTaxBenefits = false;
  bool _isProcessing = false;
  double _selectedAmount = 500.0;
  final List<double> _suggestedAmounts = [100, 500, 1000, 5000];

  @override
  void initState() {
    super.initState();

    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    // Use recommended amounts from charity if available
    if (widget.charity['recommendedAmounts'] != null) {
      try {
        final List<dynamic> rawAmounts = widget.charity['recommendedAmounts'];
        if (rawAmounts.isNotEmpty) {
          _suggestedAmounts.clear();
          for (var amount in rawAmounts) {
            // Convert all amounts to double
            _suggestedAmounts.add(amount.toDouble());
          }
          _selectedAmount = _suggestedAmounts[0]; // Default to first amount
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error setting up recommended amounts: $e');
        }
        // Keep default amounts if there's an error
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _panCardController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    _showProcessingDialog(localizations.translate('processing_donation'));

    try {
      if (kDebugMode) {
        print('Payment success: ${response.paymentId}');
        print('Order ID: ${response.orderId}');
        print('Signature: ${response.signature}');
      }

      final result = await _apiService.processDonation(
        charityId: widget.charity['id'] ?? 'kindmeals-main',
        amount: _selectedAmount,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        panCard: _requestTaxBenefits ? _panCardController.text : null,
        paymentMethod: _paymentMethod,
        requestTaxBenefits: _requestTaxBenefits,
        paymentId: response.paymentId ?? 'unknown',
      );

      _dismissDialogIfShowing();

      if (mounted) {
        _showSuccessDialog(result);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing donation: $e');
      }

      _dismissDialogIfShowing();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing donation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (kDebugMode) {
      print(
          'Payment error: Code: ${response.code}, Message: ${response.message}');
    }

    setState(() {
      _isProcessing = false;
    });

    if (mounted) {
      String errorMessage = 'Payment failed';

      // Provide more specific error messages based on error code
      switch (response.code) {
        case 2:
          errorMessage = 'Payment cancelled by user';
          break;
        case 501:
          errorMessage = 'Payment gateway error. Please try again.';
          break;
        default:
          errorMessage = response.message ?? 'Unknown payment error';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Payment through external wallet: ${response.walletName}'),
        ),
      );
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    final formatter = NumberFormat('#,##0.00');
    final dateFormatter = DateFormat('MMM dd, yyyy • hh:mm a');
    final now = DateTime.now();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 120,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                localizations.translate('thank_you'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                localizations.translate('donation_successful'),
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow(
                        'Amount', '₹${formatter.format(_selectedAmount)}'),
                    _buildReceiptRow('Date', dateFormatter.format(now)),
                    _buildReceiptRow('Payment Method', _paymentMethod),
                    _buildReceiptRow(
                        'Transaction ID', result['transaction_id'] ?? 'N/A'),
                    if (result['charity_id'] != null)
                      _buildReceiptRow('Charity', widget.charity['name']),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                localizations.translate('contribution_difference'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // Close dialogs
                      Navigator.pop(context);
                      Navigator.pop(context);

                      // Navigate to donation history
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DonationHistoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history),
                    label: Text(localizations.translate('view_history')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: Text(localizations.translate('done')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _startRazorpayPayment() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    _showProcessingDialog(localizations.translate('initializing_payment'));

    final currencyFormatter = NumberFormat('#,##0.00');
    final options = {
      'key': EnvConfig.getRazorpayKeyId(),
      'amount': (_selectedAmount * 100).round(), // Razorpay amount is in paise
      'name': 'KindMeals',
      'description':
          'Donation to ${widget.charity['name']} (${widget.charity['id']})',
      'prefill': {
        'name': _nameController.text,
        'email': _emailController.text,
        'contact': _phoneController.text,
      },
      'external': {
        'wallets': ['paytm', 'gpay']
      },
      'theme': {
        'color': '#4CAF50', // Green color in hex
      },
      'modal': {
        'animation': true,
      },
      'notes': {
        'charity_id': widget.charity['id'],
        'charity_name': widget.charity['name'],
        'payment_method': _paymentMethod,
        'request_tax_benefits': _requestTaxBenefits.toString(),
        'formatted_amount': '₹${currencyFormatter.format(_selectedAmount)}',
      },
    };

    try {
      _dismissDialogIfShowing();

      // Open the Razorpay payment sheet
      _razorpay.open(options);

      // Reset processing state after opening the payment sheet
      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error opening Razorpay: $e');
      }

      _dismissDialogIfShowing();

      setState(() {
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening payment gateway: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to show a processing dialog
  void _showProcessingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  // Helper method to dismiss dialog if showing
  void _dismissDialogIfShowing() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('make_a_donation')),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Add history button in the app bar
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Donation History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DonationHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with charity info
            _buildHeader(),

            // Donation form
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount selection
                    _buildAmountSelection(),

                    const SizedBox(height: 24),

                    // Personal information
                    Text(
                      localizations.translate('your_information'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('full_name'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.translate('enter_name');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('email'),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.translate('enter_email');
                        }
                        if (!value.contains('@')) {
                          return localizations.translate('valid_email');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: localizations.translate('phone_number'),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localizations.translate('enter_contact');
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Tax benefits checkbox
                    CheckboxListTile(
                      title: Text(localizations.translate('request_tax_benefits')),
                      value: _requestTaxBenefits,
                      onChanged: (value) {
                        setState(() {
                          _requestTaxBenefits = value ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),

                    // PAN card input if tax benefits requested
                    if (_requestTaxBenefits)
                      Column(
                        children: [
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _panCardController,
                            decoration: InputDecoration(
                              labelText: localizations.translate('pan_card_number'),
                              border: const OutlineInputBorder(),
                              helperText: localizations.translate('required_for_tax_benefits'),
                            ),
                            validator: (value) {
                              if (_requestTaxBenefits &&
                                  (value == null || value.isEmpty)) {
                                return localizations.translate('enter_id');
                              }
                              return null;
                            },
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // Payment method selection
                    Text(
                      localizations.translate('payment_method'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    _buildPaymentMethodSelector(),

                    const SizedBox(height: 32),

                    // Donate button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _startRazorpayPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isProcessing
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                'Donate ₹${NumberFormat('#,##0').format(_selectedAmount)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Privacy note
                    Text(
                      localizations.translate('information_secure'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Charity image
          if (widget.charity['imageUrl'] != null)
            SizedBox(
              height: 200,
              width: double.infinity,
              child: ImageHelper.getImage(
                imagePath: widget.charity['imageUrl'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
                backgroundColor: Colors.grey.shade200,
              ),
            ),

          // Charity info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.charity['name'] ?? 'Charity',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.charity['description'] ?? localizations.translate('support_our_cause'),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (widget.charity['impactDescription'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.charity['impactDescription'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.translate('select_amount'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _suggestedAmounts.map((amount) {
            final isSelected = _selectedAmount == amount;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedAmount = amount;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Colors.green.shade600
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  '₹${NumberFormat('#,##0').format(amount)}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Custom amount field
        TextFormField(
          decoration: InputDecoration(
            labelText: localizations.translate('custom_amount'),
            prefixText: '₹',
            border: const OutlineInputBorder(),
            hintText: NumberFormat('#,##0').format(_selectedAmount),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            if (value.isNotEmpty) {
              try {
                final amount = double.parse(value);
                if (amount > 0) {
                  setState(() {
                    _selectedAmount = amount;
                  });
                }
              } catch (e) {
                // Ignore parsing errors
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Column(
      children: [
        RadioListTile<String>(
          title: Row(
            children: [
              const Icon(Icons.account_balance),
              const SizedBox(width: 8),
              Text(localizations.translate('upi_gpay_phonepe')),
            ],
          ),
          value: 'UPI',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: Row(
            children: [
              const Icon(Icons.credit_card),
              const SizedBox(width: 8),
              Text(localizations.translate('credit_debit_card')),
            ],
          ),
          value: 'Card',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
        ),
        RadioListTile<String>(
          title: Row(
            children: [
              const Icon(Icons.account_balance_wallet),
              const SizedBox(width: 8),
              Text(localizations.translate('net_banking')),
            ],
          ),
          value: 'NetBanking',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() {
              _paymentMethod = value!;
            });
          },
        ),
      ],
    );
  }
}
