import 'package:dio/dio.dart';

class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Intercept /products request
    if (options.path == '/products') {
      final responseData = {
        'items': [
          {
            'id': '1',
            'name': 'Portland Cement (50kg)',
            'price': 8.50,
            'moq': 10,
            'vendor_id': 'v1',
            'category': 'Cement',
            'image_url': 'https://via.placeholder.com/150',
          },
          {
            'id': '2',
            'name': 'Steel Rebar (12mm)',
            'price': 12.00,
            'moq': 50,
            'vendor_id': 'v1',
            'category': 'Steel',
            'image_url': 'https://via.placeholder.com/150',
          },
        ],
      };

      return handler.resolve(
        Response(requestOptions: options, data: responseData, statusCode: 200),
      );
    }

    // Intercept /auth/login
    if (options.path == '/auth/login') {
      return handler.resolve(
        Response(
          requestOptions: options,
          data: {'token': 'mock_jwt_token_123'},
          statusCode: 200,
        ),
      );
    }

    // Intercept /orders request
    if (options.path == '/orders') {
      final responseData = {
        'items': [
          {
            'id': 'ORD-001',
            'status': 'transit',
            'items': [
              {
                'product': {
                  'id': 'p1',
                  'name': 'Portland Cement',
                  'price': 8.50,
                  'moq': 10,
                  'vendor_id': 'v1',
                  'category': 'Cement',
                  'image_url': '',
                },
                'quantity': 5,
              },
            ],
            'placed_at': '2026-02-06T10:00:00Z',
            'client_id': 'c1',
            'driver_id': 'd1',
          },
        ],
      };

      return handler.resolve(
        Response(requestOptions: options, data: responseData, statusCode: 200),
      );
    }

    return handler.next(options);
  }
}
