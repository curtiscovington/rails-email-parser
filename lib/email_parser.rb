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

		# Seperate the email into an array by the line seperator
		lines = raw_email.split(CRLF)
		puts "TESTING #{lines.count}"
		fields = raw_email.split(HEADER_SPLIT)

		parsed_email["Header"] = Hash.new
		
		found_index = -1

	
		fields.each_with_index do |field, i| 
			# Parse until we find the Content-Type
			s = field.split(FIELD_SPLIT)
			field.match(/^\s*$/) do
				
				# Ignore the first line if it is a whitespace
				if (i != 0)
					found_index = i
					break
				end
			end

			#puts s
			# This is a header field ~~~ In most cases.
			if (found_index == -1)
					if (!s[1].nil?)
						field_name = s[1]
					
						parsed_email["Header"][field_name] = s[2]
					end
			else 
				break
			end
		end

		
		if (found_index != -1) 
			# Drop all the preceeding header fields to get the body.
			s = raw_email.split(/^\s*$/)
			#puts s.count
			
			body = fields.drop(found_index+1)
			parsed_email["Body"] = body.join("\n")
			#puts body
		end

		return parsed_email
	end

end
