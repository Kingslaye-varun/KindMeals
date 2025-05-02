import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_snackbar.dart';
import '../services/api_service.dart';

class DonationScreen extends StatefulWidget {
  final String charityId;
  final String charityName;

  const DonationScreen({
    super.key,
    required this.charityId,
    required this.charityName,
  });

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _panController = TextEditingController();

  double _donationAmount = 100.0;
  String _selectedPaymentMethod = 'Credit Card';
  bool _requestTaxBenefits = false;
  bool _isProcessing = false;

  final List<double> _suggestedAmounts = [50.0, 100.0, 500.0, 1000.0, 5000.0];
  final List<String> _paymentMethods = [
    'Credit Card',
    'Debit Card',
    'UPI',
    'NetBanking'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _panController.dispose();
    super.dispose();
  }

  Future<void> _processDonation() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        _isProcessing = true;
      });

      try {
        // Generate a mock payment ID for testing
        final mockPaymentId = 'pay_${DateTime.now().millisecondsSinceEpoch}';

        final result = await ApiService().processDonation(
          charityId: widget.charityId,
          amount: _donationAmount,
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          panCard: _requestTaxBenefits ? _panController.text : null,
          paymentMethod: _selectedPaymentMethod,
          requestTaxBenefits: _requestTaxBenefits,
          paymentId: mockPaymentId,
        );

        if (result['success'] == true) {
          if (!mounted) return;

          // Show success message
          CustomSnackbar.show(
            context: context,
            message:
                'Thank you for your generous donation of ₹${_donationAmount.toStringAsFixed(0)}!',
            type: SnackbarType.success,
          );

          // Go back to previous screen after successful donation
          Navigator.of(context).pop(true);
        } else {
          if (!mounted) return;

          CustomSnackbar.show(
            context: context,
            message: result['message'] ?? 'Failed to process donation',
            type: SnackbarType.error,
          );
        }
      } catch (e) {
        if (!mounted) return;

        CustomSnackbar.show(
          context: context,
          message: 'An error occurred: $e',
          type: SnackbarType.error,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } else {
      // Form validation failed
      CustomSnackbar.show(
        context: context,
        message: 'Please fill in all required fields correctly',
        type: SnackbarType.info,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make a Donation'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Charity info
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Donating to:',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.charityName,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Donation amount section
                Text(
                  'Select Donation Amount',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                // Suggested amount chips
                Wrap(
                  spacing: 8,
                  children: _suggestedAmounts.map((amount) {
                    return ChoiceChip(
                      label: Text('₹${amount.toInt()}'),
                      selected: _donationAmount == amount,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _donationAmount = amount;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Custom amount field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Or enter custom amount (₹)',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  initialValue: _donationAmount.toInt().toString(),
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      setState(() {
                        _donationAmount = double.parse(value);
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter donation amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Personal details
                Text(
                  'Personal Details',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Payment method
                Text(
                  'Payment Method',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedPaymentMethod,
                  items: _paymentMethods.map((method) {
                    return DropdownMenuItem<String>(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPaymentMethod = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Tax benefits
                SwitchListTile(
                  title: const Text('I want tax benefits'),
                  value: _requestTaxBenefits,
                  onChanged: (value) {
                    setState(() {
                      _requestTaxBenefits = value;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),

                if (_requestTaxBenefits) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _panController,
                    decoration: const InputDecoration(
                      labelText: 'PAN Card Number',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    validator: (value) {
                      if (_requestTaxBenefits &&
                          (value == null || value.isEmpty)) {
                        return 'PAN card is required for tax benefits';
                      }
                      if (_requestTaxBenefits &&
                          !RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$')
                              .hasMatch(value!)) {
                        return 'Please enter a valid PAN number';
                      }
                      return null;
                    },
                  ),
                ],

                const SizedBox(height: 32),

                // Donate button
                ElevatedButton(
                  onPressed: _isProcessing ? null : _processDonation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator()
                      : Text('Donate ₹${_donationAmount.toStringAsFixed(0)}'),
                ),

                const SizedBox(height: 16),

                // Security notice
                const Center(
                  child: Text(
                    'All payments are secure and encrypted',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
