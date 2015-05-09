-- example itemLink: |cff9d9d9d|Hitem:7073:0:0:0:0:0:0:0|h[Broken Fang]|h|r
-- local itemName, _, itemId, itemString, itemRarity, itemColor, itemLevel, _, itemType, itemSubType, _, _, _, _ = MRT_GetDetailedItemInformation(itemLink);5

local AUCTION_NOT_RUNNING = 0
local WRONG_BID_TYPE = 1
local BID_REQ_FAILED = 2

local E = {
    AUCTION_NOT_RUNNING = "No auction is currently running.",
    WRONG_BID_TYPE = "Bid type [%s] not available.",
    BID_REQ_FAILED = "Bid requirement failed: %s.",
}


PA_LootAuction = {
    check_bid_req = {},
    on_auction_queue_end = nil,
    on_auction_end = nil,
    stored = {
        bid_types = { "normal", "trial", "low", "off" },
        auction_len = 60,
        auction_queue = {},
        auction_running = false,
        auction_queue_running = false,
        cur_auction_index = nil,
        cur_auction = nil,
        timers = {
            ["auction"] = nil,
        },
    },
}

local LA = PA_LootAuction

function LA:AddItemToAuctionQueue(item)
    if self:IsAuctionRunning() then
        return nil
    end
    self.stored.auction_queue:insert({["item"] = item})
end

function LA:ClearAuctionQueue()
    if self:IsAuctionRunning() or self:IsAuctionQueueRunning() then
        return nil
    end

    self.stored.auction_queue = {}
end

function LA:EndAuctionQueue()
    self.stored.cur_auction_index = nil
    self.stored.auction_queue_running = false
    if self.on_auction_queue_end then
        self.on_auction_queue_end()
    end
end

function LA:HandleBid(bid_type, amount, bidder)
    if self:IsAuctionRunning() then
        return nil, E[AUCTION_NOT_RUNNING]
    end
    
    if not self.bid_type[bid_type] then
        return nil, E[WRONG_BID_TYPE].format(bid_type)
    end
    
    if self.check_bid_req[bid_type] then
        local success, err = self.check_bid_req[bid_type]()
        if not success then
            return false, E[BID_REQ_FAILED].format(err)
        end
    end
    
    self.stored.cur_auction["bids"][bid_type]:insert({ 
        ["bidder"] = bidder,
        ["amount"] = amount
    })
end

function LA:IsAuctionRunning()
    return self.stored.auction_running
end

function LA:IsAuctionQueueRunning()
    return self.stored.auction_queue_running
end

function LA:OnAuctionEnd()
    self.stored.timers["auction"] = nil
    
    if self.on_auction_end then
        self.on_auction_end(self.stored.cur_auction)
    end
    
    self.stored.cur_auction = nil
    self.stored.auction_running = false
end

function LA:GetWinner()
    if not self.stored.cur_auction then
        return nil
    end
    
    local winners = {}
    
    for _, bid_type in pairs(self.stored.bid_types) do
        for _, bid in pairs(self.stored.cur_auctions["bids"][bid_type]) do
            if not winners[1] then
                winners[1] = {
                    ["bidder"] = bid["bidder"],
                    ["amount"] = bid["amount"]
                }
            elseif bid["amount"] > winners[1]["amount"] then
                winners = {}
                winners[1] = {
                    ["bidder"] = bid["bidder"],
                    ["amount"] = bid["amount"]
                }
            elseif bid ["amount"] == winners[1]["amount"] then
                winners:insert({
                    ["bidder"] = bid["bidder"],
                    ["amount"] = bid["amount"]
                })
            end
        end
        
        if winners[1] then
            break
        end
    end
end

function LA:StartAuction(auction)
    if self:IsAuctionRunning() then
        return nil
    end
    self.stored.auction_running = true
    self.stored.cur_auction = auction
    self.stored.timers["auction"] = self.stored.auction_len
end

function LA:StartAuctionQueue()
    if self:IsAuctionQueueRunning() then
        return nil
    end
    self.stored.auction_queue_running = true
    self:StartNextAuction()
end

function LA:StartNextAuction()
    if not self.stored.cur_auction_index then
        self.stored.cur_auction_index = 1
    else
        self.stored.cur_auction_index = self.stored.cur_auction_index + 1
    end
    
    if not self.stored.auctions_queue[self.stored.cur_auction_index] then
        self:EndAuctionQueue()
    else
        local auction = 
            self.stored.auction_queue[self.stored.cur_auction_index]
            
        for i, bid_type in pairs(self.stored_bitype) do
            auction["bids"][bid_type] = {}
        end
        
        auction["winner"] = nil
        
        self:StartAuction(auction)
    end
end
