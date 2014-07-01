class EmailParser
	# Using http://tools.ietf.org/html/rfc2822


	CRLF 		  = /\r\n/
	WSP 		  = /[\x9\x20]/
	FIELD_NAME    = /[\x21-\x39\x3b-\x7e]+/
	FIELD_BODY    = /.+/m
	FIELD_SPLIT   = /^(#{FIELD_NAME})\s*:\s*(#{FIELD_BODY})?$/
	HEADER_SPLIT  = /#{CRLF}(?!#{WSP})/

	def self.parse(raw_email)
		parsed_email = Hash.new

		# Seperate the email into an array by the header
		fields, body = raw_email.split(/#{CRLF}#{WSP}*#{CRLF}/m, 2)
	
		header_fields = fields.split(HEADER_SPLIT)

		parsed_email["Header"] = parse_headers(header_fields)

		if (!parsed_email["Header"]["Content-Type"].nil?)
			content_type = parsed_email["Header"]["Content-Type"];
		else
			content_type = "text/plain"
		end
		
	
		
		parsed_email["Body"] = parse_body(content_type, body)
		
		return parsed_email
	end

	private 
	
	# Returns a new hash of the header fields
	def self.parse_headers(header_fields)
		headers = Hash.new
		if (!header_fields.nil?)
			header_fields.each do |field|
				s = field.split(FIELD_SPLIT)
				if (!s[1].nil?)
					field_name = s[1]
					headers[field_name] = s[2]
				end
			end
		end

		return headers
	end

	def self.parse_body(content_type,raw_body)
		mime = parse_mime_type(content_type)

		new_body = String.new
		if (mime["Type"] == "multipart")
			boundary = parse_boundary(content_type)
			new_body = parse_multipart_body(boundary, raw_body)
		else 
			new_body = raw_body
		end

		return new_body
	end

	def self.parse_multipart_body(boundary, raw_body)
		new_body = String.new

		parts = raw_body.split(/(:\A|\r\n)--#{boundary}(?=(?:--)?\s*$)/)

		parts.each do |part|
			# Can save these parts for use elsewhere
			# For the simple purpose of this, just append to body.
			fields, body = part.split(/#{CRLF}#{WSP}*#{CRLF}/m, 2)

			# Give a default content type
			part_content_type = "text/plain"

			if (!fields.nil?)
				headers = parse_headers(fields.split(HEADER_SPLIT))
				if (!headers["Content-Type"].nil?)
					part_content_type = headers["Content-Type"]
				end
			end
			if (!body.nil?)
				new_body += parse_body(part_content_type, body)
			end
		end

		return new_body
	end

	def self.parse_boundary(content_type)
		boundary_equation = content_type.match(/boundary=[a-zA-Z0-9]+/)[0]
		boundary = boundary_equation.split("=")[1]

		return boundary
	end

	def self.parse_mime_type(content_type)
		match = content_type.match(/^[a-zA-Z]+\/[a-zA-Z]+;?/)[0]

		m = match.scan(/[a-zA-Z]+/)
		type = m[0]
		subtype = m[1]

		return Hash["Type", m[0], "Subtype", m[1]]
	end
end
