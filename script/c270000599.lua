-- Effect: If this card is Normal Summoned: You can add 1 "Pot of Greed", and if you do, banish this monster until the end of this chain.
local s,id=GetID()
function s.initial_effect(c)
	-- Add "Pot of Greed" to hand and banish this card until the end of the chain
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0)) -- Effect description
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_REMOVE) -- Categories for searching, adding to hand, and banishing
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O) -- Trigger effect
	e1:SetCode(EVENT_SPSUMMON_SUCCESS) -- Activates when the monster is Normal Summoned
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY) -- Proper flag to make it activate in chain
	e1:SetCountLimit(1,id) -- Once per turn
	e1:SetTarget(s.target) -- Target function
	e1:SetOperation(s.operation) -- Operation function
	c:RegisterEffect(e1)
end

-- Target: Add "Pot of Greed" to hand
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

-- Filter: "Pot of Greed"
function s.filter(c)
	return c:IsCode(55144522) and c:IsAbleToHand() -- "Pot of Greed" card code and ensuring it can be added to the hand
end

-- Operation: Add "Pot of Greed" to hand and banish this card until end of chain
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- Search and add "Pot of Greed"
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)

		-- Banish this card until the end of the chain
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.Remove(c,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)
			-- Return this card to the field at the end of the chain
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAIN_END)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetLabelObject(c)
			e1:SetOperation(s.retop)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

-- Return the card to the field at the end of the chain
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ReturnToField(e:GetLabelObject())
end