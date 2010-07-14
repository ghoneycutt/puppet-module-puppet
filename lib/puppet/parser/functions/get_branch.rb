module Puppet::Parser::Functions
    newfunction(:get_branch, :type => :rvalue) do |args|
        # Function to provide branch from which our puppetmaster will checkout/switch/update/revert
        # getting configuration over http from our puppetrepo using open-uri
        require 'open-uri'

        # this function is being called from puppet::server, 2 arguments expected pop and the url for the config file
        pop     = args[0]
        url     = args[1]

        def getValue(str,url)
            begin
                # grep for the first line with our pop from our config file
                ourLine = URI.parse("#{url}").open.read.grep(/#{str}/)[0]

                # if our pop is not described in the config the function will return nothing. The default value will be obtained later, by calling it again with another str
                return if ! ourLine

                # otherwise we will split the line taking the second argument
                branch  = ourLine.chomp!.split[1]
                if branch
                    return branch
                else
                    #return branch   = "broken"
                    return branch
                end
            # whichever error it is SocketError or OpenURI::HTTPError, it is broken
            rescue
                return branch   = "broken_rescued_getValue"
            end
        end

        # Gettign the value. If our pop is not in the config file(function returned nil), we will try to use default
        ourBranch    = getValue(pop,url)
        if ! ourBranch
            ourBranch    = getValue("default",url)
            #ourBranch    = "broken" if ! ourBranch
        end

        # here we go
        ourBranch
    end
end
