class EmailParser
	# Using http://tools.ietf.org/html/rfc2822


	CRLF = /\r\n/
	WSP = /[\x9\x20]/
	FIELD_NAME = /[\x21-\x39\x3b-\x7e]+/
	FIELD_BODY    = /.+/m
	FIELD_SPLIT   = /^(#{FIELD_NAME})\s*:\s*(#{FIELD_BODY})?$/
	HEADER_SPLIT  = /#{CRLF}(?!#{WSP})/

	def self.parse(raw_email)
		parsed_email = Hash.new

		# Seperate the email into an array by the header
		fields = raw_email.split(HEADER_SPLIT)

		parsed_email["Header"] = Hash.new

		body_index = start_of_body_index(fields)

		if (body_index != -1)
			header_fields = fields.shift(body_index)
			parsed_email["Body"] = fields.join("\r\n")
		end

		parsed_email["Header"] = headers(header_fields)


		return parsed_email
	end

	private 

	# Returns the index where the body begins
	def self.start_of_body_index(fields)

		fields.each_with_index do |field, i|
			if m = field.match(/^\s*$/)
				if (i != 0)
					return i
				end
			end
		end

		# No match found
		return -1
	end

	# Returns a new hash of the header fields
	def self.headers(header_fields)
		headers = Hash.new
		header_fields.each_with_index do |field, i|
			s = field.split(FIELD_SPLIT)
			if (!s[1].nil?)
				field_name = s[1]
				headers[field_name] = s[2]
			end
		end

		return headers
	end
end
