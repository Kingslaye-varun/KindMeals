import 'package:flutter/material.dart';
import '../../models/charity_model.dart';
import '../../services/charity_service.dart';
import 'charity_donation_screen.dart';
import '../../utils/app_localizations.dart';

class CharityListScreen extends StatefulWidget {
  const CharityListScreen({Key? key}) : super(key: key);

  @override
  State<CharityListScreen> createState() => _CharityListScreenState();
}

class _CharityListScreenState extends State<CharityListScreen> {
  final CharityService _charityService = CharityService();
  bool _isLoading = true;
  List<CharityModel> _charities = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCharities();
  }

  Future<void> _loadCharities() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final charities = await _charityService.getCharities();

      if (mounted) {
        setState(() {
          _charities = charities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load charities: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('donate_to_charity')),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCharities,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView(localizations)
              : _charities.isEmpty
                  ? _buildEmptyView(localizations)
                  : _buildCharityList(localizations),
    );
  }

  Widget _buildErrorView(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate('error'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCharities,
            child: Text(localizations.translate('try_again')),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.volunteer_activism,
            size: 80,
            color: Colors.green.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.translate('no_charities_available'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.translate('check_back_later'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadCharities,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(localizations.translate('refresh')),
          ),
        ],
      ),
    );
  }

  Widget _buildCharityList(AppLocalizations localizations) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header section
        _buildHeaderSection(localizations),
        const SizedBox(height: 24),

        // Charity list
        ..._charities.map((charity) => _buildCharityCard(charity, localizations)).toList(),
      ],
    );
  }

  Widget _buildHeaderSection(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.translate('make_a_difference'),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          localizations.translate('contribution_help'),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildCharityCard(CharityModel charity, AppLocalizations localizations) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CharityDonationScreen(
                charity: charity.toJson(),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: charity.imageUrl.startsWith('http')
                  ? Image.network(
                      charity.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.volunteer_activism,
                              size: 60,
                              color: Colors.orange.shade300,
                            ),
                          ),
                        );
                      },
                    )
                  : Image.asset(
                      charity.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: Icon(
                              Icons.volunteer_activism,
                              size: 60,
                              color: Colors.orange.shade300,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade100),
                    ),
                    child: Text(
                      localizations.translate('food_relief'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    charity.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    charity.description,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${localizations.translate('from')} ₹${charity.recommendedAmounts.first.toInt()}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CharityDonationScreen(
                                charity: charity.toJson(),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        child: Text(localizations.translate('donate_now')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
