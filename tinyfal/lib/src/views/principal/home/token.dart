import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tinyfal/src/models/resource.dart';
import 'package:tinyfal/src/models/client_user.dart';

class TokenManagementCard extends StatefulWidget {
  final Resource resource;
  final ClientUser? clientUser;
  final Function(String)? onTokenRegenerated;

  const TokenManagementCard({
    super.key,
    required this.resource,
    required this.clientUser,
    this.onTokenRegenerated,
  });

  @override
  State<TokenManagementCard> createState() => _TokenManagementCardState();
}

class _TokenManagementCardState extends State<TokenManagementCard> {
  bool _isTokenVisible = false;
  bool _isRegenerating = false;

  String get _maskedToken {
    final token = widget.resource.token;
    if (token == null || token.isEmpty) return "No token generated";
    return "••••••••••••••••••••••••••••••••";
  }

  String get _displayToken {
    final token = widget.resource.token;
    if (token == null || token.isEmpty) return "No token generated";
    return _isTokenVisible ? token : _maskedToken;
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    required Color confirmColor,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          content: Text(content, style: TextStyle(color: Colors.grey[600])),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  void _toggleTokenVisibility() {
    _showConfirmationDialog(
      title: _isTokenVisible ? "Hide Token" : "Show Token",
      content: _isTokenVisible
          ? "Are you sure you want to hide the token?"
          : "Are you sure you want to reveal the token? Make sure you're in a secure environment.",
      confirmText: _isTokenVisible ? "Hide" : "Show",
      confirmColor: _isTokenVisible ? Colors.orange : Colors.blue,
      onConfirm: () {
        setState(() {
          _isTokenVisible = !_isTokenVisible;
        });
      },
    );
  }

  void _regenerateToken() {
    _showConfirmationDialog(
      title: "Regenerate Token",
      content:
          "Are you sure you want to regenerate the token? This will invalidate the current token and may affect any services using it.",
      confirmText: "Regenerate",
      confirmColor: Colors.red,
      onConfirm: () async {
        setState(() {
          _isRegenerating = true;
        });

        try {
          // Ensure the resource has the clientUser set for Firestore operations
          if (widget.clientUser != null) {
            widget.resource.clientUser = widget.clientUser;
          }

          // Use the Resource class methods for token generation
          if (widget.resource.token == null || widget.resource.token!.isEmpty) {
            // Create new token if none exists
            await widget.resource.createToken();
          } else {
            // Regenerate existing token
            await widget.resource.regenerateToken();
          }

          // Call callback if provided
          widget.onTokenRegenerated?.call(widget.resource.token!);

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Token regenerated successfully"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          // Show error message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Failed to regenerate token: $e"),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {
              _isRegenerating = false;
            });
          }
        }
      },
    );
  }

  void _copyToken() {
    final token = widget.resource.token;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("No token to copy"),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: token));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Token copied to clipboard"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasToken =
        widget.resource.token != null && widget.resource.token!.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Access Token Management",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 20),

          // Token Display Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Token",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          _displayToken,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: hasToken
                                ? Colors.grey[800]
                                : Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                    if (hasToken) ...[
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: _copyToken,
                        icon: Icon(Icons.copy, size: 20),
                        tooltip: "Copy token",
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue[50],
                          foregroundColor: Colors.blue[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              if (hasToken) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRegenerating ? null : _toggleTokenVisibility,
                    icon: Icon(
                      _isTokenVisible ? Icons.visibility_off : Icons.visibility,
                      size: 18,
                    ),
                    label: Text(_isTokenVisible ? "Hide Token" : "Show Token"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.blue[600],
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
              ],
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRegenerating ? null : _regenerateToken,
                  icon: _isRegenerating
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(Icons.refresh, size: 18),
                  label: Text(
                    _isRegenerating
                        ? "Regenerating..."
                        : hasToken
                        ? "Regenerate Token"
                        : "Generate Token",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasToken
                        ? Colors.red[50]
                        : Colors.green[50],
                    foregroundColor: hasToken
                        ? Colors.red[600]
                        : Colors.green[600],
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // Security Notice
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.security, color: Colors.amber[700], size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Security Notice",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.amber[800],
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Keep your token secure and don't share it publicly. Regenerating the token will invalidate the current one.",
                        style: TextStyle(
                          color: Colors.amber[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
