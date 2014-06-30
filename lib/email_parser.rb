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

		body_index = start_of_body_index(fields)

		if (body_index != -1)
			header_fields = fields.shift(body_index)
			body = fields.join("\r\n")
		end

		parsed_email["Header"] = headers(header_fields)

		if (!parsed_email["Header"]["Content-Type"].nil?)
			content_type = parsed_email["Header"]["Content-Type"];
		else
			content_type = "text/plain"
		end

		parsed_email["Body"] = parse_body(content_type, body)

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

	def self.parse_body(content_type,raw_body)

		mime_type = content_type.match(/^[a-zA-Z]+\/[a-zA-Z]+;?/)[0]
		
		m = mime_type.scan(/[a-zA-Z]+/)
		type = m[0]
		subtype = m[1]
		new_body = ""
		if (type == "multipart")
			boundary_equation = content_type.match(/boundary=[a-zA-Z0-9]+/)[0]
			boundary = boundary_equation.split("=")[1]
			
			parts = raw_body.split(/(:\A|\r\n)--#{boundary}(?=(?:--)?\s*$)/)
			parts[1...-1].to_a.each_with_index do |part, i|
				# Can save these parts for use elsewhere
				# For the simple purpose of this, just append to body.
				new_body += part
			end
		else 
			new_body = raw_body
		end

		return new_body
	end
end
