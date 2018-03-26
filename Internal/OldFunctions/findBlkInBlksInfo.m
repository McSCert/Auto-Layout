function idx = findBlkInBlksInfo(blxInfo, blk)
    for z = 1:length(blxInfo)
        if strcmp(blxInfo(z).fullname, blk{1})
            idx = z;
            return
        end
    end
    error('Block not found in blxInfo');
end