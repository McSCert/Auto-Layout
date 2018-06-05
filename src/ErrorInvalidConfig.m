function ErrorInvalidConfig(config)
    % Call this if a configuration setting was given an invalid value
    %
    % config is the name of the config, not value.
    
    error(['Error using ' mfilename ':' char(10) ...
        ' Invalid config parameter: ' config '.' char(10) ...
        ' Please fix in the config.txt.'])
end