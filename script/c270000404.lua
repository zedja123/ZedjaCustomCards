--Build Rider - Misora
local s,id,o=GetID()
function s.initial_effect(c)
	-- Special Summon from hand if only control "Build Rider" monsters
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetCountLimit(1, {id, 1})
	c:RegisterEffect(e1)

	-- Banish this card from GY and banish opponent's card to Special Summon banished "Build Rider"
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1, {id, 2})
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		and not Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.spfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0xf15)
end

-- Cost function: Banish this card from the Graveyard
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter_banished, tp, LOCATION_REMOVED, 0, 1, nil)
			and Duel.IsExistingMatchingCard(s.filter_grave, tp, 0, LOCATION_GRAVE, 1, nil) end
	local g1=Duel.GetMatchingGroup(s.filter_banished, tp, LOCATION_REMOVED, 0, nil)
	local g2=Duel.GetMatchingGroup(s.filter_grave, tp, 0, LOCATION_GRAVE, nil)
end

-- Target function: Check for valid targets and set operation info
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.filter_banished, tp, LOCATION_REMOVED, 0, 1, nil)
			and Duel.IsExistingMatchingCard(s.filter_grave, tp, 0, LOCATION_GRAVE, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 2, tp, LOCATION_GRAVE)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_REMOVED)
end

-- Filter function for banished "Build Rider" monsters
function s.filter_banished(c)
	return c:IsSetCard(0xf15) and c:IsFaceup() and c:IsAbleToRemove()
end

-- Filter function for opponent's cards in the Graveyard
function s.filter_grave(c)
	return c:IsAbleToRemove()
end

-- Operation function: Remove selected cards and special summon the banished monster
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc1=Duel.SelectMatchingCard(tp, s.filter_banished, tp, LOCATION_REMOVED, 0, 1, 1, nil):GetFirst()
	local tc2=Duel.SelectMatchingCard(tp, s.filter_grave, tp, 0, LOCATION_GRAVE, 1, 1, nil):GetFirst()
	if tc1 and tc2 then
		-- Banish the selected cards
		Duel.Remove(tc1, POS_FACEUP, REASON_EFFECT)
		Duel.Remove(tc2, POS_FACEUP, REASON_EFFECT)
		Duel.Remove(e:GetHandler(), POS_FACEUP, REASON_COST)
		-- Special summon the banished "Build Rider" monster
		Duel.SpecialSummon(tc1, 0, tp, tp, false, false, POS_FACEUP)
		
		-- Negate the effects of the summoned monster
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc1:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc1:RegisterEffect(e2)
	end
end