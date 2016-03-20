require 'test_helper'

module Jpush
  module Api
    class DeviceTest < Jpush::Test

      def setup
        @devices = @@jPush.devices
      end

      def test_show
        response = @devices.show($test_common_registration_id)
        assert_equal 200, response.http_code

        body = response.body
        assert_true body.has_key?('tags')
        assert_true body.has_key?('alias')
        assert_true body.has_key?('mobile')
        assert_instance_of(Array, body['tags'])
      end

      def test_show_with_invalid_registration_id
        response = @devices.show('INVALID_REGISTRATION_ID')
        assert_equal 400, response.http_code
        assert_equal 7002, response.error[:code]
      end

      def test_update
        assert_raises ArgumentError do
          @devices.update($test_common_registration_id)
        end
      end

      def test_add_and_remove_tags
        body = @devices.show($test_common2_registration_id).body
        assert_false body['tags'].include?($test_common_tag)

        response = @devices.add_tags($test_common2_registration_id, $test_common_tag)
        assert_equal 200, response.http_code

        body = @devices.show($test_common2_registration_id).body
        assert_true body['tags'].include?($test_common_tag)

        response = @devices.remove_tags($test_common2_registration_id, $test_common_tag)
        assert_equal 200, response.http_code

        body = @devices.show($test_common2_registration_id).body
        assert_false body['tags'].include?($test_common_tag)
      end

      def test_add_invalid_tag_value
        @tags = @@jPush.tags
        invalid_tag = 'INVALID_TAG'

        body = @tags.list.body
        assert_false body['tags'].include?(invalid_tag)
        before_tag_len = body['tags'].length

        body = @devices.show($test_common_registration_id).body
        assert_false body['tags'].include?(invalid_tag)

        response = @devices.add_tags($test_common_registration_id, invalid_tag)
        assert_equal 200, response.http_code

        body = @devices.show($test_common_registration_id).body
        assert_true body['tags'].include?(invalid_tag)

        body = @tags.list.body
        assert_true body['tags'].include?(invalid_tag)
        after_tag_len = body['tags'].length
        assert_equal 1, after_tag_len - before_tag_len

        @tags.delete(invalid_tag)

        body = @devices.show($test_common_registration_id).body
        assert_false body['tags'].include?(invalid_tag)

        body = @tags.list.body
        assert_false body['tags'].include?(invalid_tag)
        final_tag_len = body['tags'].length

        assert_equal final_tag_len, before_tag_len
      end

      def test_remove_invalid_tag_value
        @tags = @@jPush.tags
        invalid_tag = 'INVALID_TAG'

        body = @tags.list.body
        assert_false body['tags'].include?(invalid_tag)

        body = @devices.show($test_common_registration_id).body
        assert_false body['tags'].include?(invalid_tag)
        before_tag_len = body['tags'].length

        response = @devices.remove_tags($test_common_registration_id, invalid_tag)
        assert_equal 200, response.http_code

        body = @devices.show($test_common_registration_id).body
        assert_false body['tags'].include?(invalid_tag)
        after_tag_len = body['tags'].length

        assert_equal before_tag_len, after_tag_len
      end

      def test_add_and_remove_tags_with_invalid_registration_id
        response = @devices.add_tags('INVALID_REGISTRATION_ID', $test_common_tag)
        assert_equal 400, response.http_code
        assert_equal 7002, response.error[:code]

        response = @devices.remove_tags('INVALID_REGISTRATION_ID', $test_common_tag)
        assert_equal 400, response.http_code
        assert_equal 7002, response.error[:code]
      end

      def test_clear_tags
        body = @devices.show($test_common2_registration_id).body
        assert_false body['tags'].include?($test_common_tag)

        @devices.add_tags($test_common2_registration_id, $test_common_tag)

        body = @devices.show($test_common2_registration_id).body
        assert_true body['tags'].include?($test_common_tag)

        response = @devices.clear_tags($test_common2_registration_id)
        assert_equal 200, response.http_code

        body = @devices.show($test_common2_registration_id).body
        assert_false body['tags'].include?($test_common_tag)
        assert_true body['tags'].empty?
      end

      def test_build_tags
        assert_raises ArgumentError do
          @devices.send(:build_tags, '')
        end
        assert_raises ArgumentError do
          @devices.send(:build_tags, ' ')
        end
        assert_raises ArgumentError do
          @devices.send(:build_tags, [])
        end
        assert_raises ArgumentError do
          @devices.send(:build_tags, ['', ' ', '   ', [], [''], [' '], nil])
        end

        tags = @devices.send(:build_tags, ['tag1', 'tag2'])
        assert_instance_of(Array, tags)
        assert_equal 2, tags.length

        tags = @devices.send(:build_tags, ['tag1', 'tag2', '', ' ', '   ', [], [''], [' '], nil])
        assert_instance_of(Array, tags)
        assert_equal 2, tags.length

        tags = @devices.send(:build_tags, 'tag')
        assert_instance_of(Array, tags)
        assert_equal 1, tags.length
      end

      def test_update_alias
        body = @devices.show($test_common_registration_id).body
        origin_alias = body['alias']

        response = @devices.update_alias($test_common_registration_id, 'JPUSH')
        assert_equal 200, response.http_code

        body = @devices.show($test_common_registration_id).body
        assert_equal 'JPUSH', body['alias']

        response = @devices.update_alias($test_common_registration_id, '')
        assert_equal 200, response.http_code

        body = @devices.show($test_common_registration_id).body
        assert_nil body['alias']

        unless origin_alias.nil?
          response = @devices.update_alias($test_common_registration_id, origin_alias)
          assert_equal 200, response.http_code

          body = @devices.show($test_common_registration_id).body
          assert_equal origin_alias, body['alias']
        end
      end

      def test_update_mobile
        body = @devices.show($test_common_registration_id).body
        origin_mobile = body['mobile'] || 13888888888

        response = @devices.update_mobile($test_common_registration_id, '13800138000')
        assert_equal 200, response.http_code

        body = @devices.show($test_common_registration_id).body
        assert_equal 13800138000, body['mobile']

        response = @devices.update_mobile($test_common_registration_id, origin_mobile.to_s)
        assert_equal 200, response.http_code

        body = @devices.show($test_common_registration_id).body
        assert_equal origin_mobile, body['mobile']
      end

      def test_device_status
        # TODO
        # need vip appKey
      end

    end
  end
end
